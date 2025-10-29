const express = require('express');
const { supabaseAdmin } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all favorites for the authenticated user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const { data: favorites, error } = await supabaseAdmin
      .from('favorites')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });
    
    if (error) {
      console.error('Error fetching favorites:', error);
      return res.status(500).json({ error: 'Failed to fetch favorites' });
    }
    
    res.json({ favorites: favorites || [] });
  } catch (error) {
    console.error('Get favorites error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get favorites by type (offers, players, clubs)
router.get('/:type', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { type } = req.params;
    
    if (!['offer', 'player', 'club'].includes(type)) {
      return res.status(400).json({ error: 'Invalid favorite type' });
    }
    
    const { data: favorites, error } = await supabaseAdmin
      .from('favorites')
      .select('*')
      .eq('user_id', userId)
      .eq('item_type', type)
      .order('created_at', { ascending: false });
    
    if (error) {
      console.error('Error fetching favorites:', error);
      return res.status(500).json({ error: 'Failed to fetch favorites' });
    }
    
    // Fetch the actual items
    const itemIds = favorites.map(f => f.item_id);
    
    if (type === 'offer') {
      const { data: offers, error: offersError } = await supabaseAdmin
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
        .in('id', itemIds);
      
      if (offersError) {
        console.error('Error fetching offers:', offersError);
        return res.status(500).json({ error: 'Failed to fetch favorite offers' });
      }
      
      return res.json({ favorites: offers || [] });
    } else if (type === 'player' || type === 'club') {
      const role = type === 'player' ? 'player' : 'club';
      const { data: users, error: usersError } = await supabaseAdmin
        .from('users')
        .select('*')
        .eq('role', role)
        .in('id', itemIds);
      
      if (usersError) {
        console.error('Error fetching users:', usersError);
        return res.status(500).json({ error: 'Failed to fetch favorite users' });
      }
      
      // Remove passwords
      const safeUsers = users.map(user => {
        const { password, ...safeUser } = user;
        return safeUser;
      });
      
      return res.json({ favorites: safeUsers || [] });
    }
    
    res.json({ favorites: [] });
  } catch (error) {
    console.error('Get favorites by type error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Check if an item is favorited
router.get('/check/:type/:id', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { type, id } = req.params;
    
    console.log(`🔍 Checking favorite - User: ${userId}, Type: ${type}, ID: ${id}`);
    
    if (!['offer', 'player', 'club'].includes(type)) {
      return res.status(400).json({ error: 'Invalid favorite type' });
    }
    
    const { data: favorite, error } = await supabaseAdmin
      .from('favorites')
      .select('id')
      .eq('user_id', userId)
      .eq('item_type', type)
      .eq('item_id', id)
      .single();
    
    if (error) {
      // PGRST116 = no rows returned (normal, c'est juste pas favori)
      if (error.code === 'PGRST116') {
        console.log(`✅ Favorite not found - Item ${type}/${id} is not favorited by user ${userId}`);
        return res.json({ isFavorite: false });
      }
      console.error('❌ Error checking favorite:', error);
      return res.status(500).json({ error: 'Failed to check favorite', details: error.message });
    }
    
    console.log(`✅ Favorite found - Item ${type}/${id} is favorited by user ${userId}`);
    res.json({ isFavorite: !!favorite });
  } catch (error) {
    console.error('❌ Check favorite error:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// Add a favorite
router.post('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { item_type, item_id } = req.body;
    
    console.log(`➕ Add favorite - User: ${userId}, Type: ${item_type}, ID: ${item_id}`);
    
    if (!item_type || !item_id) {
      console.error('❌ Missing required fields');
      return res.status(400).json({ error: 'item_type and item_id are required' });
    }
    
    if (!['offer', 'player', 'club'].includes(item_type)) {
      console.error('❌ Invalid item_type:', item_type);
      return res.status(400).json({ error: 'Invalid item_type' });
    }
    
    // Verify the item exists
    let itemExists = false;
    if (item_type === 'offer') {
      const { data } = await supabaseAdmin
        .from('offers')
        .select('id')
        .eq('id', item_id)
        .single();
      itemExists = !!data;
    } else {
      const { data } = await supabaseAdmin
        .from('users')
        .select('id')
        .eq('id', item_id)
        .eq('role', item_type === 'player' ? 'player' : 'club')
        .single();
      itemExists = !!data;
    }
    
    if (!itemExists) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    // Check if already favorited
    const { data: existing } = await supabaseAdmin
      .from('favorites')
      .select('id')
      .eq('user_id', userId)
      .eq('item_type', item_type)
      .eq('item_id', item_id)
      .single();
    
    if (existing) {
      return res.status(200).json({ message: 'Already favorited', favorite: existing });
    }
    
    // Create favorite
    console.log(`💾 Inserting favorite into database...`);
    const { data: favorite, error } = await supabaseAdmin
      .from('favorites')
      .insert([{
        user_id: userId,
        item_type,
        item_id
      }])
      .select()
      .single();
    
    if (error) {
      console.error('❌ Error creating favorite:', error);
      console.error('   Error code:', error.code);
      console.error('   Error message:', error.message);
      return res.status(500).json({ error: 'Failed to add favorite', details: error.message });
    }
    
    console.log('✅ Favorite created successfully:', favorite.id);
    res.status(201).json({ message: 'Favorite added', favorite });
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Remove a favorite
router.delete('/:type/:id', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { type, id } = req.params;
    
    console.log(`🗑️ Remove favorite - User: ${userId}, Type: ${type}, ID: ${id}`);
    
    if (!['offer', 'player', 'club'].includes(type)) {
      return res.status(400).json({ error: 'Invalid favorite type' });
    }
    
    const { error, count } = await supabaseAdmin
      .from('favorites')
      .delete()
      .eq('user_id', userId)
      .eq('item_type', type)
      .eq('item_id', id);
    
    if (error) {
      console.error('❌ Error deleting favorite:', error);
      return res.status(500).json({ error: 'Failed to remove favorite', details: error.message });
    }
    
    console.log(`✅ Favorite removed (${count || 0} deleted)`);
    res.json({ message: 'Favorite removed' });
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;

