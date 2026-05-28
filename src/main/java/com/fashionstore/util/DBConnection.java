package com.fashionstore.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // Database URL
    private static final String URL = "jdbc:mysql://localhost:3306/fashion_store?useSSL=false&serverTimezone=UTC";

    // Database credentials
    private static final String USER = "root";       // change if needed
    private static final String PASSWORD = "********";   // change if needed

    // Get Connection Method
    public static Connection getConnection() {
        Connection connection = null;

        try {
            // Load MySQL Driver (optional for newer versions, but safe)
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Establish connection
            connection = DriverManager.getConnection(URL, USER, PASSWORD);

            System.out.println("Database Connected Successfully!");

        } catch (ClassNotFoundException e) {
            System.out.println("MySQL Driver not found!");
            e.printStackTrace();

        } catch (SQLException e) {
            System.out.println("Connection Failed!");
            e.printStackTrace();
        }

        return connection;
    }
}
