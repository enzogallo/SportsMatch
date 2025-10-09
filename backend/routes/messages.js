const express = require('express');
const { supabase } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get conversations for a user
router.get('/conversations', authenticateToken, async (req, res) => {
  try {
    const user = req.user;

    // Get conversations where user is a participant
    const { data: conversations, error } = await supabase
      .from('conversations')
      .select(`
        id,
        last_message,
        last_activity_at,
        unread_count,
        participants:conversation_participants(
          user:users(
            id,
            name,
            profile_image_url,
            club_name
          )
        )
      `)
      .contains('participant_ids', [user.id])
      .order('last_activity_at', { ascending: false });

    if (error) {
      console.error('Error fetching conversations:', error);
      return res.status(500).json({ error: 'Failed to fetch conversations' });
    }

    res.json({ conversations: conversations || [] });

  } catch (error) {
    console.error('Conversations error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get messages in a conversation
router.get('/conversations/:conversationId/messages', authenticateToken, async (req, res) => {
  try {
    const { conversationId } = req.params;
    const user = req.user;
    const { page = 1, limit = 50 } = req.query;

    // Check if user is part of the conversation
    const { data: conversation, error: convError } = await supabase
      .from('conversations')
      .select('participant_ids')
      .eq('id', conversationId)
      .single();

    if (convError || !conversation) {
      return res.status(404).json({ error: 'Conversation not found' });
    }

    if (!conversation.participant_ids.includes(user.id)) {
      return res.status(403).json({ error: 'Not authorized to view this conversation' });
    }

    // Get messages
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    const { data: messages, error } = await supabase
      .from('messages')
      .select(`
        id,
        content,
        type,
        is_read,
        created_at,
        sender:users!messages_sender_id_fkey(
          id,
          name,
          profile_image_url
        )
      `)
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: false })
      .range(from, to);

    if (error) {
      console.error('Error fetching messages:', error);
      return res.status(500).json({ error: 'Failed to fetch messages' });
    }

    // Mark messages as read
    await supabase
      .from('messages')
      .update({ is_read: true })
      .eq('conversation_id', conversationId)
      .neq('sender_id', user.id);

    res.json({ 
      messages: (messages || []).reverse(),
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit)
      }
    });

  } catch (error) {
    console.error('Messages error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Send a message
router.post('/conversations/:conversationId/messages', authenticateToken, async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { content, type = 'text' } = req.body;
    const user = req.user;

    if (!content || content.trim().length === 0) {
      return res.status(400).json({ error: 'Message content is required' });
    }

    // Check if user is part of the conversation
    const { data: conversation, error: convError } = await supabase
      .from('conversations')
      .select('participant_ids')
      .eq('id', conversationId)
      .single();

    if (convError || !conversation) {
      return res.status(404).json({ error: 'Conversation not found' });
    }

    if (!conversation.participant_ids.includes(user.id)) {
      return res.status(403).json({ error: 'Not authorized to send messages to this conversation' });
    }

    // Create message
    const { data: message, error } = await supabase
      .from('messages')
      .insert([{
        conversation_id: conversationId,
        sender_id: user.id,
        content: content.trim(),
        type,
        is_read: false,
        created_at: new Date().toISOString()
      }])
      .select(`
        id,
        content,
        type,
        is_read,
        created_at,
        sender:users!messages_sender_id_fkey(
          id,
          name,
          profile_image_url
        )
      `)
      .single();

    if (error) {
      console.error('Error creating message:', error);
      return res.status(500).json({ error: 'Failed to send message' });
    }

    // Update conversation last activity
    await supabase
      .from('conversations')
      .update({
        last_message: content.trim(),
        last_activity_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .eq('id', conversationId);

    res.status(201).json({
      message: 'Message sent successfully',
      data: message
    });

  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create or get conversation between two users
router.post('/conversations', authenticateToken, async (req, res) => {
  try {
    const { otherUserId } = req.body;
    const user = req.user;

    if (!otherUserId) {
      return res.status(400).json({ error: 'Other user ID is required' });
    }

    if (otherUserId === user.id) {
      return res.status(400).json({ error: 'Cannot create conversation with yourself' });
    }

    // Check if conversation already exists
    const { data: existingConv, error: checkError } = await supabase
      .from('conversations')
      .select('id')
      .contains('participant_ids', [user.id, otherUserId])
      .single();

    if (existingConv) {
      return res.json({ 
        message: 'Conversation already exists',
        conversation: existingConv
      });
    }

    // Create new conversation
    const { data: conversation, error } = await supabase
      .from('conversations')
      .insert([{
        participant_ids: [user.id, otherUserId],
        last_activity_at: new Date().toISOString(),
        unread_count: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select(`
        id,
        participant_ids,
        last_activity_at,
        unread_count,
        participants:conversation_participants(
          user:users(
            id,
            name,
            profile_image_url,
            club_name
          )
        )
      `)
      .single();

    if (error) {
      console.error('Error creating conversation:', error);
      return res.status(500).json({ error: 'Failed to create conversation' });
    }

    res.status(201).json({
      message: 'Conversation created successfully',
      conversation
    });

  } catch (error) {
    console.error('Create conversation error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
