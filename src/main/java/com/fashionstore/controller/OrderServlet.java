package com.fashionstore.controller;

import java.io.IOException;
import java.util.List;

import com.fashionstore.dao.OrderDAO;
import com.fashionstore.dao.CartDAO;
import com.fashionstore.dao.impl.OrderDAOImpl;
import com.fashionstore.dao.impl.CartDAOImpl;
import com.fashionstore.model.Order;
import com.fashionstore.model.OrderItem;
import com.fashionstore.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/order")
public class OrderServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private OrderDAO orderDAO = new OrderDAOImpl();
    private CartDAO  cartDAO  = new CartDAOImpl();

    // -------------------------------------------------------
    // GET — my orders / order detail / place order confirm
    // -------------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Must be logged in
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user?action=login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "myOrders";

        switch (action) {

            case "placeOrder":
                handlePlaceOrder(request, response, user);
                break;

            case "orderDetail":
                handleOrderDetail(request, response, user);
                break;

            case "myOrders":
            default:
                handleMyOrders(request, response, user);
                break;
        }
    }

    // -------------------------------------------------------
    // Place order
    // -------------------------------------------------------
    private void handlePlaceOrder(HttpServletRequest request,
                                   HttpServletResponse response,
                                   User user)
            throws ServletException, IOException {

        // Check cart is not empty
        int cartSize = cartDAO.getCartItemsByUserId(user.getId()).size();
        if (cartSize == 0) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        boolean success = orderDAO.placeOrder(user.getId());

        if (success) {
            // Redirect to my orders with success flag
            response.sendRedirect(request.getContextPath()
                    + "/order?action=myOrders&placed=true");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/cart?error=orderFailed");
        }
    }

    // -------------------------------------------------------
    // My Orders list
    // -------------------------------------------------------
    private void handleMyOrders(HttpServletRequest request,
                                 HttpServletResponse response,
                                 User user)
            throws ServletException, IOException {

        List<Order> orders = orderDAO.getOrdersByUserId(user.getId());

        request.setAttribute("orders", orders);

        // Flash message after placing order
        if ("true".equals(request.getParameter("placed"))) {
            request.setAttribute("successMsg",
                    "Your order has been placed successfully!");
        }

        request.getRequestDispatcher("/WEB-INF/views/orders.jsp")
               .forward(request, response);
    }

    // -------------------------------------------------------
    // Order detail
    // -------------------------------------------------------
    private void handleOrderDetail(HttpServletRequest request,
                                    HttpServletResponse response,
                                    User user)
            throws ServletException, IOException {

        String orderIdParam = request.getParameter("orderId");

        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/order?action=myOrders");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdParam.trim());
            Order order = orderDAO.getOrderById(orderId);

            // Security check — user can only see their own orders
            if (order == null || order.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/order?action=myOrders");
                return;
            }

            List<OrderItem> orderItems = orderDAO.getOrderItemsByOrderId(orderId);

            request.setAttribute("order",      order);
            request.setAttribute("orderItems", orderItems);

            request.getRequestDispatcher("/WEB-INF/views/order-detail.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/order?action=myOrders");
        }
    }
}