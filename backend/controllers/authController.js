const User = require('../models/User');
const jwt = require('jsonwebtoken');
const config = require('../config/environment');

// Generate JWT Token
const signToken = (id) => {
  return jwt.sign({ id }, config.jwtSecret, {
    expiresIn: process.env.JWT_EXPIRES_IN || '30d'
  });
};

// Register user
exports.register = async (req, res) => {
  try {
    const { name, email, phone, village, district, state, password } = req.body;

    // Check if user exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({
        success: false,
        message: 'User already exists with this email'
      });
    }

    // Create user
    const user = await User.create({
      name,
      email,
      phone,
      village,
      district,
      state,
      password
    });

    // Generate token
    const token = signToken(user._id);

    res.status(201).json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        village: user.village,
        district: user.district,
        state: user.state
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Login user
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check if user exists and password is correct
    const user = await User.findOne({ email }).select('+password');
    if (!user || !(await user.correctPassword(password, user.password))) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Generate token
    const token = signToken(user._id);

    res.status(200).json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        village: user.village,
        district: user.district,
        state: user.state,
        languagePreference: user.languagePreference
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};