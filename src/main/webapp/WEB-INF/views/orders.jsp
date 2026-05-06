<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.fashionstore.model.Order" %>
<%@ page import="com.fashionstore.model.User" %>

<%
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    User user = (User) session.getAttribute("user");
    boolean isEmpty = orders == null || orders.isEmpty();
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Orders — FashionStore</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/order.css">
</head>
<body>

<!-- ── Nav ── -->
<nav class="top-nav">
  <a href="${pageContext.request.contextPath}/products" class="nav-logo">FASHION<span>.</span></a>
  <ul class="nav-links">
    <li><a href="${pageContext.request.contextPath}/products">Shop</a></li>
    <li><a href="${pageContext.request.contextPath}/user?action=profile"><%= user.getName().split(" ")[0] %></a></li>
    <li><a href="${pageContext.request.contextPath}/order?action=myOrders" class="active">Orders</a></li>
    <li><a href="${pageContext.request.contextPath}/cart" class="nav-cart">Cart</a></li>
    <li><a href="${pageContext.request.contextPath}/user?action=logout">Sign out</a></li>
  </ul>
</nav>

<div class="page-body">

  <!-- ── Header ── -->
  <div class="page-header">
    <p class="page-eyebrow">Account</p>
    <h1 class="page-title">My Orders</h1>
  </div>

  <div class="main-content">

    <!-- Success flash -->
    <% if (request.getAttribute("successMsg") != null) { %>
      <div class="alert alert-success">
        &#10003; &nbsp;${successMsg}
      </div>
    <% } %>

    <% if (!isEmpty) { %>

      <div class="orders-list">
        <% for (Order order : orders) {
             String statusClass = "status-placed";
             if ("SHIPPED".equalsIgnoreCase(order.getStatus()))    statusClass = "status-shipped";
             if ("DELIVERED".equalsIgnoreCase(order.getStatus()))  statusClass = "status-delivered";
             if ("CANCELLED".equalsIgnoreCase(order.getStatus()))  statusClass = "status-cancelled";
        %>
          <a href="${pageContext.request.contextPath}/order?action=orderDetail&orderId=<%= order.getId() %>"
             class="order-card">

            <div class="order-card-left">
              <p class="order-id">Order #<%= order.getId() %></p>
              <div class="order-meta">
                <span>&#128197; <%= sdf.format(order.getOrderDate()) %></span>
              </div>
              <span class="order-status <%= statusClass %>"><%= order.getStatus() %></span>
            </div>

            <div>
              <p class="order-amount">&#8377;<%= String.format("%.0f", order.getTotalAmount()) %></p>
              <p class="order-arrow" style="text-align:right;">&#8250;</p>
            </div>

          </a>
        <% } %>
      </div>

    <% } else { %>

      <div class="empty-orders">
        <div class="empty-orders-icon">
          <svg width="80" height="80" viewBox="0 0 24 24" fill="none"
               stroke="currentColor" stroke-width="0.8">
            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
            <polyline points="14,2 14,8 20,8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
            <polyline points="10,9 9,9 8,9"/>
          </svg>
        </div>
        <h2>No orders yet</h2>
        <p>You haven't placed any orders. Start shopping to see them here.</p>
        <a href="${pageContext.request.contextPath}/products" class="btn-shop">
          Browse Collection
        </a>
      </div>

    <% } %>

  </div>

  <footer class="site-footer">
    <div class="footer-logo">FASHION<span>.</span></div>
    <p class="footer-note">&copy; 2025 FashionStore. All rights reserved.</p>
  </footer>

</div>
</body>
</html>
