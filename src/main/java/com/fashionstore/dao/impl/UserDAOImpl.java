package com.fashionstore.dao.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Random;

import org.mindrot.jbcrypt.BCrypt;

import com.fashionstore.dao.UserDAO;
import com.fashionstore.model.User;
import com.fashionstore.util.DBConnection;
import com.fashionstore.util.EmailService;

public class UserDAOImpl implements UserDAO {

    @Override
    public boolean registerUser(User user) {

        String query = "INSERT INTO users (name, email, password, address_line, city, state, pincode) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, BCrypt.hashpw(user.getPassword(), BCrypt.gensalt()));
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
        String query = "SELECT * FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String hashedPassword = rs.getString("password");

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

    // -------------------------------------------------------
    // Step 1: Generate 6-digit OTP, save to DB, email it
    // -------------------------------------------------------
    @Override
    public boolean generateAndSendOtp(String email) {

        if (!isEmailExists(email)) {
            System.out.println("[OTP] No account found for email: " + email);
            return false;
        }

        String otp = String.format("%06d", new Random().nextInt(999999));
        LocalDateTime expiry = LocalDateTime.now().plusMinutes(10);

        String query = "UPDATE users SET otp = ?, otp_expiry = ? WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, otp);
            ps.setTimestamp(2, Timestamp.valueOf(expiry));
            ps.setString(3, email);
            ps.executeUpdate();

        } catch (Exception e) {
            System.out.println("[OTP] DB error while saving OTP for " + email);
            e.printStackTrace();
            return false;
        }

        boolean emailSent = EmailService.sendOtpEmail(email, otp);
        if (!emailSent) {
            System.out.println("[OTP] Email exists and OTP was saved, but EmailService failed to send to: " + email);
        }
        return emailSent;
    }

    // -------------------------------------------------------
    // Step 2: Verify OTP, reset password if valid
    // -------------------------------------------------------
    @Override
    public boolean resetPasswordWithOtp(String email, String otp, String newPassword) {

        String query = "SELECT otp, otp_expiry FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) return false;

            String savedOtp  = rs.getString("otp");
            Timestamp expiry = rs.getTimestamp("otp_expiry");

            if (savedOtp == null || expiry == null)                     return false;
            if (!savedOtp.equals(otp))                                  return false;
            if (expiry.toLocalDateTime().isBefore(LocalDateTime.now())) return false;

            // OTP valid — update password and clear OTP fields
            String updateQuery = "UPDATE users SET password = ?, otp = NULL, otp_expiry = NULL WHERE email = ?";
            try (PreparedStatement updatePs = conn.prepareStatement(updateQuery)) {
                updatePs.setString(1, BCrypt.hashpw(newPassword, BCrypt.gensalt()));
                updatePs.setString(2, email);
                return updatePs.executeUpdate() > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}
