package com.fashionstore.dao;

import com.fashionstore.model.User;

public interface UserDAO {

    // Register new user
    boolean registerUser(User user);

    // Login user
    User loginUser(String email, String password);

    // Get user by ID (for profile page)
    User getUserById(int userId);

    // Update user profile (including address)
    boolean updateUser(User user);

    // Check if email already exists (for registration validation)
    boolean isEmailExists(String email);

    // Generate OTP, store it in DB, and email it to the user
    boolean generateAndSendOtp(String email);

    // Verify OTP and reset password if correct
    boolean resetPasswordWithOtp(String email, String otp, String newPassword);
}