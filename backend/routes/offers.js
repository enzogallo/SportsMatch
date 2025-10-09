const express = require('express');
const { supabase } = require('../config/database');
const { authenticateToken, optionalAuth } = require('../middleware/auth');

const router = express.Router();

// Get all offers with filters
router.get('/', optionalAuth, async (req, res) => {
  try {
    const { 
      sport, 
      city, 
      level, 
      position, 
      page = 1, 
      limit = 20,
      status = 'active'
    } = req.query;

    let query = supabase
      .from('offers')
      .select(`
        *,
        club:users!offers_club_id_fkey(
          id,
          name,
          club_name,
          city,
          location
        )
      `)
      .eq('status', status)
      .order('created_at', { ascending: false });

    // Apply filters
    if (sport) {
      query = query.eq('sport', sport);
    }
    if (city) {
      query = query.ilike('city', `%${city}%`);
    }
    if (level) {
      query = query.eq('level', level);
    }
    if (position) {
      query = query.ilike('position', `%${position}%`);
    }

    // Pagination
    const from = (page - 1) * limit;
    const to = from + limit - 1;
    query = query.range(from, to);

    const { data: offers, error, count } = await query;

    if (error) {
      console.error('Error fetching offers:', error);
      return res.status(500).json({ error: 'Failed to fetch offers' });
    }

    res.json({
      offers: offers || [],
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count || 0,
        pages: Math.ceil((count || 0) / limit)
      }
    });

  } catch (error) {
    console.error('Offers error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get offer by ID
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const { id } = req.params;

    const { data: offer, error } = await supabase
      .from('offers')
      .select(`
        *,
        club:users!offers_club_id_fkey(
          id,
          name,
          club_name,
          city,
          location,
          contact_email,
          contact_phone
        )
      `)
      .eq('id', id)
      .single();

    if (error || !offer) {
      return res.status(404).json({ error: 'Offer not found' });
    }

    res.json({ offer });

  } catch (error) {
    console.error('Offer error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create offer (clubs only)
router.post('/', authenticateToken, async (req, res) => {
  try {
    const user = req.user;

    if (user.role !== 'club') {
      return res.status(403).json({ error: 'Only clubs can create offers' });
    }

    const {
      title,
      description,
      sport,
      position,
      level,
      type = 'recruitment',
      location,
      city,
      min_age,
      max_age,
      is_urgent = false,
      max_applications
    } = req.body;

    // Validation
    if (!title || !description || !sport || !location || !city) {
      return res.status(400).json({ error: 'Required fields missing' });
    }

    const offerData = {
      club_id: user.id,
      title,
      description,
      sport,
      position,
      level,
      type,
      location,
      city,
      min_age: min_age ? parseInt(min_age) : null,
      max_age: max_age ? parseInt(max_age) : null,
      is_urgent: Boolean(is_urgent),
      max_applications: max_applications ? parseInt(max_applications) : null,
      status: 'active',
      current_applications: 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const { data: offer, error } = await supabase
      .from('offers')
      .insert([offerData])
      .select(`
        *,
        club:users!offers_club_id_fkey(
          id,
          name,
          club_name,
          city,
          location
        )
      `)
      .single();

    if (error) {
      console.error('Error creating offer:', error);
      return res.status(500).json({ error: 'Failed to create offer' });
    }

    res.status(201).json({
      message: 'Offer created successfully',
      offer
    });

  } catch (error) {
    console.error('Create offer error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update offer (club owner only)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const user = req.user;

    // Check if offer exists and user owns it
    const { data: existingOffer, error: fetchError } = await supabase
      .from('offers')
      .select('club_id')
      .eq('id', id)
      .single();

    if (fetchError || !existingOffer) {
      return res.status(404).json({ error: 'Offer not found' });
    }

    if (existingOffer.club_id !== user.id) {
      return res.status(403).json({ error: 'Not authorized to update this offer' });
    }

    const updateData = {
      ...req.body,
      updated_at: new Date().toISOString()
    };

    const { data: offer, error } = await supabase
      .from('offers')
      .update(updateData)
      .eq('id', id)
      .select(`
        *,
        club:users!offers_club_id_fkey(
          id,
          name,
          club_name,
          city,
          location
        )
      `)
      .single();

    if (error) {
      console.error('Error updating offer:', error);
      return res.status(500).json({ error: 'Failed to update offer' });
    }

    res.json({
      message: 'Offer updated successfully',
      offer
    });

  } catch (error) {
    console.error('Update offer error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete offer (club owner only)
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const user = req.user;

    // Check if offer exists and user owns it
    const { data: existingOffer, error: fetchError } = await supabase
      .from('offers')
      .select('club_id')
      .eq('id', id)
      .single();

    if (fetchError || !existingOffer) {
      return res.status(404).json({ error: 'Offer not found' });
    }

    if (existingOffer.club_id !== user.id) {
      return res.status(403).json({ error: 'Not authorized to delete this offer' });
    }

    const { error } = await supabase
      .from('offers')
      .delete()
      .eq('id', id);

    if (error) {
      console.error('Error deleting offer:', error);
      return res.status(500).json({ error: 'Failed to delete offer' });
    }

    res.json({ message: 'Offer deleted successfully' });

  } catch (error) {
    console.error('Delete offer error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
