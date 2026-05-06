package com.fashionstore.controller;

import java.io.IOException;
import java.util.List;

import com.fashionstore.dao.CartDAO;
import com.fashionstore.dao.ProductDAO;
import com.fashionstore.dao.impl.CartDAOImpl;
import com.fashionstore.dao.impl.ProductDAOImpl;
import com.fashionstore.model.Product;
import com.fashionstore.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/products")
public class ProductServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private ProductDAO productDAO = new ProductDAOImpl();
    private CartDAO cartDAO = new CartDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String categoryIdParam = request.getParameter("categoryId");
        String keyword = request.getParameter("search");

        List<Product> products;

        // Filter / Search Logic
        if ((categoryIdParam != null && !categoryIdParam.isEmpty()) ||
            (keyword != null && !keyword.isEmpty())) {

            Integer categoryId = null;

            if (categoryIdParam != null && !categoryIdParam.isEmpty()) {
                categoryId = Integer.parseInt(categoryIdParam);
            }

            products = productDAO.filterProducts(categoryId, keyword);

        } else {
            products = productDAO.getAllProducts();
        }

        request.setAttribute("products", products);

        // ===== Cart Count Logic =====
        User user = (User) request.getSession().getAttribute("user");

        if (user != null) {
            int count = cartDAO.getCartItemsByUserId(user.getId()).size();
            request.setAttribute("cartCount", count);
        }

        request.getRequestDispatcher("/WEB-INF/views/products.jsp")
               .forward(request, response);
    }
}