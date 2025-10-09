const express = require('express');
const { supabase } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get applications for a user
router.get('/my', authenticateToken, async (req, res) => {
  try {
    const user = req.user;

    const { data: applications, error } = await supabase
      .from('applications')
      .select(`
        *,
        offer:offers(
          id,
          title,
          sport,
          city,
          status,
          club:users!offers_club_id_fkey(
            id,
            name,
            club_name
          )
        )
      `)
      .eq('player_id', user.id)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching applications:', error);
      return res.status(500).json({ error: 'Failed to fetch applications' });
    }

    res.json({ applications: applications || [] });

  } catch (error) {
    console.error('Applications error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get applications for an offer (club owner only)
router.get('/offer/:offerId', authenticateToken, async (req, res) => {
  try {
    const { offerId } = req.params;
    const user = req.user;

    // Check if user owns the offer
    const { data: offer, error: offerError } = await supabase
      .from('offers')
      .select('club_id')
      .eq('id', offerId)
      .single();

    if (offerError || !offer) {
      return res.status(404).json({ error: 'Offer not found' });
    }

    if (offer.club_id !== user.id) {
      return res.status(403).json({ error: 'Not authorized to view these applications' });
    }

    const { data: applications, error } = await supabase
      .from('applications')
      .select(`
        *,
        player:users!applications_player_id_fkey(
          id,
          name,
          age,
          city,
          sports,
          position,
          level,
          bio,
          profile_image_url
        )
      `)
      .eq('offer_id', offerId)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching applications:', error);
      return res.status(500).json({ error: 'Failed to fetch applications' });
    }

    res.json({ applications: applications || [] });

  } catch (error) {
    console.error('Applications error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create application
router.post('/', authenticateToken, async (req, res) => {
  try {
    const user = req.user;

    if (user.role !== 'player') {
      return res.status(403).json({ error: 'Only players can apply to offers' });
    }

    const { offer_id, message } = req.body;

    if (!offer_id) {
      return res.status(400).json({ error: 'Offer ID is required' });
    }

    // Check if offer exists and is active
    const { data: offer, error: offerError } = await supabase
      .from('offers')
      .select('id, status, max_applications, current_applications')
      .eq('id', offer_id)
      .single();

    if (offerError || !offer) {
      return res.status(404).json({ error: 'Offer not found' });
    }

    if (offer.status !== 'active') {
      return res.status(400).json({ error: 'This offer is no longer active' });
    }

    if (offer.max_applications && offer.current_applications >= offer.max_applications) {
      return res.status(400).json({ error: 'This offer has reached maximum applications' });
    }

    // Check if user already applied
    const { data: existingApplication } = await supabase
      .from('applications')
      .select('id')
      .eq('offer_id', offer_id)
      .eq('player_id', user.id)
      .single();

    if (existingApplication) {
      return res.status(400).json({ error: 'You have already applied to this offer' });
    }

    // Create application
    const { data: application, error } = await supabase
      .from('applications')
      .insert([{
        offer_id,
        player_id: user.id,
        message: message || null,
        status: 'pending',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select(`
        *,
        offer:offers(
          id,
          title,
          sport,
          city,
          club:users!offers_club_id_fkey(
            id,
            name,
            club_name
          )
        )
      `)
      .single();

    if (error) {
      console.error('Error creating application:', error);
      return res.status(500).json({ error: 'Failed to create application' });
    }

    // Update offer application count
    await supabase
      .from('offers')
      .update({ 
        current_applications: offer.current_applications + 1,
        updated_at: new Date().toISOString()
      })
      .eq('id', offer_id);

    res.status(201).json({
      message: 'Application submitted successfully',
      application
    });

  } catch (error) {
    console.error('Create application error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update application status (club owner only)
router.put('/:id/status', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const user = req.user;

    if (!['pending', 'accepted', 'rejected', 'withdrawn'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    // Get application with offer info
    const { data: application, error: fetchError } = await supabase
      .from('applications')
      .select(`
        *,
        offer:offers(
          id,
          club_id,
          title
        )
      `)
      .eq('id', id)
      .single();

    if (fetchError || !application) {
      return res.status(404).json({ error: 'Application not found' });
    }

    // Check if user owns the offer
    if (application.offer.club_id !== user.id) {
      return res.status(403).json({ error: 'Not authorized to update this application' });
    }

    // Update application
    const { data: updatedApplication, error } = await supabase
      .from('applications')
      .update({
        status,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)
      .select(`
        *,
        player:users!applications_player_id_fkey(
          id,
          name,
          email
        ),
        offer:offers(
          id,
          title
        )
      `)
      .single();

    if (error) {
      console.error('Error updating application:', error);
      return res.status(500).json({ error: 'Failed to update application' });
    }

    res.json({
      message: 'Application status updated successfully',
      application: updatedApplication
    });

  } catch (error) {
    console.error('Update application error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Withdraw application (player only)
router.put('/:id/withdraw', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const user = req.user;

    // Check if application exists and belongs to user
    const { data: application, error: fetchError } = await supabase
      .from('applications')
      .select('id, player_id, offer_id, status')
      .eq('id', id)
      .single();

    if (fetchError || !application) {
      return res.status(404).json({ error: 'Application not found' });
    }

    if (application.player_id !== user.id) {
      return res.status(403).json({ error: 'Not authorized to withdraw this application' });
    }

    if (application.status !== 'pending') {
      return res.status(400).json({ error: 'Cannot withdraw application that is not pending' });
    }

    // Update application status
    const { error } = await supabase
      .from('applications')
      .update({
        status: 'withdrawn',
        updated_at: new Date().toISOString()
      })
      .eq('id', id);

    if (error) {
      console.error('Error withdrawing application:', error);
      return res.status(500).json({ error: 'Failed to withdraw application' });
    }

    // Decrease offer application count
    await supabase
      .from('offers')
      .update({ 
        current_applications: supabase.raw('current_applications - 1'),
        updated_at: new Date().toISOString()
      })
      .eq('id', application.offer_id);

    res.json({ message: 'Application withdrawn successfully' });

  } catch (error) {
    console.error('Withdraw application error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
