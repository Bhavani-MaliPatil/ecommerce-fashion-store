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

    // Reset user password by verifying email and pincode
    boolean resetPassword(String email, String pincode, String newPassword);
}