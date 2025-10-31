const express = require('express');
const { supabase, supabaseAdmin } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get user profile
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const { data: user, error } = await supabase
      .from('users')
      .select(`
        id,
        name,
        email,
        role,
        age,
        city,
        sports,
        position,
        level,
        bio,
        profile_image_url,
        performance_cv,
        club_name,
        club_logo_url,
        club_description,
        contact_email,
        contact_phone,
        sports_offered,
        location,
        status,
        created_at,
        updated_at
      `)
      .eq('id', id)
      .single();

    if (error || !user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user });

  } catch (error) {
    console.error('User error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user performance CV
router.get('/:id/performance', async (req, res) => {
  try {
    const { id } = req.params;
    const { sport } = req.query;
    const { data: user, error } = await supabase
      .from('users')
      .select('id, performance_cv')
      .eq('id', id)
      .single();
    if (error || !user) {
      return res.status(404).json({ error: 'User not found' });
    }
    const cv = user.performance_cv || null;
    if (sport && cv && typeof cv === 'object') {
      return res.json({ performance: cv[sport] || null });
    }
    res.json({ performance: cv });
  } catch (error) {
    console.error('Get performance error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update user performance CV (self only)
router.put('/:id/performance', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const user = req.user;
    if (user.id !== id) {
      return res.status(403).json({ error: 'Not authorized to update this profile' });
    }
    const { sport, performance } = req.body || {};

    // Fetch current CV to merge
    const { data: currentUser } = await supabaseAdmin
      .from('users')
      .select('performance_cv')
      .eq('id', id)
      .single();
    const currentCV = currentUser?.performance_cv || {};

    let newCV;
    if (sport) {
      newCV = { ...currentCV, [sport]: performance };
    } else {
      // If no sport provided, replace whole object
      newCV = performance;
    }

    const { data, error } = await supabaseAdmin
      .from('users')
      .update({ performance_cv: newCV, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select('id, performance_cv')
      .single();
    if (error) {
      console.error('Error updating performance:', error);
      return res.status(500).json({ error: 'Failed to update performance' });
    }
    const responsePerformance = sport ? data.performance_cv?.[sport] || null : data.performance_cv;
    res.json({ message: 'Performance updated', performance: responsePerformance });
  } catch (error) {
    console.error('Update performance error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update user profile
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const user = req.user;

    // Check if user is updating their own profile
    if (user.id !== id) {
      return res.status(403).json({ error: 'Not authorized to update this profile' });
    }

    const updateData = {
      ...req.body,
      updated_at: new Date().toISOString()
    };

    // Remove fields that shouldn't be updated directly
    delete updateData.id;
    delete updateData.email;
    delete updateData.password;
    delete updateData.role;
    delete updateData.created_at;

    const { data: updatedUser, error } = await supabaseAdmin
      .from('users')
      .update(updateData)
      .eq('id', id)
      .select(`
        id,
        name,
        email,
        role,
        age,
        city,
        sports,
        position,
        level,
        bio,
        profile_image_url,
        performance_cv,
        club_name,
        club_logo_url,
        club_description,
        contact_email,
        contact_phone,
        sports_offered,
        location,
        status,
        created_at,
        updated_at
      `)
      .single();

    if (error) {
      console.error('Error updating user:', error);
      return res.status(500).json({ error: 'Failed to update profile' });
    }

    res.json({
      message: 'Profile updated successfully',
      user: updatedUser
    });

  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Search users
router.get('/', async (req, res) => {
  try {
    const { 
      role, 
      sport, 
      city, 
      level, 
      position,
      page = 1, 
      limit = 20 
    } = req.query;

    let query = supabase
      .from('users')
      .select(`
        id,
        name,
        role,
        age,
        city,
        sports,
        position,
        level,
        bio,
        profile_image_url,
        club_name,
        club_logo_url,
        location,
        status,
        created_at,
        updated_at
      `)
      .order('created_at', { ascending: false });

    // Apply filters
    if (role) {
      query = query.eq('role', role);
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
    if (sport) {
      query = query.contains('sports', [sport]);
    }

    // Pagination
    const from = (page - 1) * limit;
    const to = from + limit - 1;
    query = query.range(from, to);

    const { data: users, error, count } = await query;

    if (error) {
      console.error('Error searching users:', error);
      return res.status(500).json({ error: 'Failed to search users' });
    }

    res.json({
      users: users || [],
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count || 0,
        pages: Math.ceil((count || 0) / limit)
      }
    });

  } catch (error) {
    console.error('Search users error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user's offers (for clubs)
router.get('/:id/offers', async (req, res) => {
  try {
    const { id } = req.params;
    const { page = 1, limit = 20, status = 'active' } = req.query;

    // Check if user is a club
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('role')
      .eq('id', id)
      .single();

    if (userError || !user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (user.role !== 'club') {
      return res.status(400).json({ error: 'User is not a club' });
    }

    let query = supabase
      .from('offers')
      .select('*')
      .eq('club_id', id)
      .order('created_at', { ascending: false });

    if (status) {
      query = query.eq('status', status);
    }

    // Pagination
    const from = (page - 1) * limit;
    const to = from + limit - 1;
    query = query.range(from, to);

    const { data: offers, error, count } = await query;

    if (error) {
      console.error('Error fetching user offers:', error);
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
    console.error('User offers error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
