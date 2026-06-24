package com.fashionstore.dao.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import org.mindrot.jbcrypt.BCrypt;

import com.fashionstore.dao.UserDAO;
import com.fashionstore.model.User;
import com.fashionstore.util.DBConnection;

public class UserDAOImpl implements UserDAO {

    @Override
    public boolean registerUser(User user) {

        String query = "INSERT INTO users (name, email, password, address_line, city, state, pincode) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, BCrypt.hashpw(user.getPassword(), BCrypt.gensalt())); // ← hashed
            ps.setString(4, user.getAddressLine());
            ps.setString(5, user.getCity());
            ps.setString(6, user.getState());
            ps.setString(7, user.getPincode());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public User loginUser(String email, String password) {

        User user = null;
        // Only filter by email — password checked with BCrypt below
        String query = "SELECT * FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String hashedPassword = rs.getString("password");

                // BCrypt compares plain text with stored hash
                if (BCrypt.checkpw(password, hashedPassword)) {
                    user = new User();
                    user.setId(rs.getInt("id"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(hashedPassword);
                    user.setAddressLine(rs.getString("address_line"));
                    user.setCity(rs.getString("city"));
                    user.setState(rs.getString("state"));
                    user.setPincode(rs.getString("pincode"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }

    @Override
    public User getUserById(int userId) {

        User user = null;
        String query = "SELECT * FROM users WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setId(rs.getInt("id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setAddressLine(rs.getString("address_line"));
                user.setCity(rs.getString("city"));
                user.setState(rs.getString("state"));
                user.setPincode(rs.getString("pincode"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }

    @Override
    public boolean updateUser(User user) {

        String query = "UPDATE users SET name=?, email=?, password=?, address_line=?, city=?, state=?, pincode=? WHERE id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());

            // Only hash if not already hashed (starts with $2a$ = BCrypt hash)
            String pwd = user.getPassword();
            if (!pwd.startsWith("$2a$")) {
                pwd = BCrypt.hashpw(pwd, BCrypt.gensalt());
            }
            ps.setString(3, pwd);

            ps.setString(4, user.getAddressLine());
            ps.setString(5, user.getCity());
            ps.setString(6, user.getState());
            ps.setString(7, user.getPincode());
            ps.setInt(8, user.getId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean isEmailExists(String email) {

        String query = "SELECT id FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            return rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}