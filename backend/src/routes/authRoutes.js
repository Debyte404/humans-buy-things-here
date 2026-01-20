import express from 'express';
import { protect } from '../middleware/authMiddleware.js';
import User from '../models/User.js';

const router = express.Router();

// @desc Verify user status (check if user exists in DB)
// @route POST /api/auth/verify
// @access Private
router.post('/verify', protect, async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid });

    if (user) {
      if (user.isBanned) {
        return res.status(403).json({ message: 'User is banned' });
      }
      return res.status(200).json({
        onboarded: true,
        user: {
          id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          avatar: user.avatar,
        },
      });
    } else {
      return res.status(200).json({
        onboarded: false,
        message: 'Proceed to onboarding',
      });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
});

// @desc Complete user onboarding
// @route POST /api/auth/onboard
// @access Private
router.post('/onboard', protect, async (req, res) => {
  const { firstName, lastName, address1, address2, pincode } = req.body;

  try {
    const userExists = await User.findOne({ firebaseUid: req.user.uid });

    if (userExists) {
      return res.status(400).json({ message: 'User already onboarded' });
    }

    const { uid, email, picture } = req.user;

    const user = await User.create({
      firebaseUid: uid,
      email: email,
      firstName,
      lastName,
      address1,
      address2,
      pincode,
      avatar: picture,
    });

    if (user) {
      res.status(201).json({
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        avatar: user.avatar,
      });
    } else {
      res.status(400).json({ message: 'Invalid user data' });
    }
  } catch (error) {
    console.error(error);
    res.status(400).json({ message: error.message });
  }
});

export default router;
