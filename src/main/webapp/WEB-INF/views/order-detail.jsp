<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.fashionstore.model.Order" %>
<%@ page import="com.fashionstore.model.OrderItem" %>
<%@ page import="com.fashionstore.model.User" %>

<%
    Order order           = (Order) request.getAttribute("order");
    List<OrderItem> items = (List<OrderItem>) request.getAttribute("orderItems");
    User user             = (User) session.getAttribute("user");
    SimpleDateFormat sdf  = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

    String statusClass = "status-placed";
    if ("SHIPPED".equalsIgnoreCase(order.getStatus()))    statusClass = "status-shipped";
    if ("DELIVERED".equalsIgnoreCase(order.getStatus()))  statusClass = "status-delivered";
    if ("CANCELLED".equalsIgnoreCase(order.getStatus()))  statusClass = "status-cancelled";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Order #<%= order.getId() %> — FashionStore</title>
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

  <!-- ── Breadcrumb ── -->
  <div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/order?action=myOrders">My Orders</a>
    <span class="breadcrumb-sep">&#8250;</span>
    <span class="breadcrumb-current">Order #<%= order.getId() %></span>
  </div>

  <!-- ── Detail Grid ── -->
  <div class="detail-grid">

    <!-- Left: items -->
    <div class="detail-card">
      <p class="detail-card-title">Order Items</p>

      <% if (items != null && !items.isEmpty()) { %>
        <% for (OrderItem item : items) { %>
          <div class="order-item-row">
            <div>
              <p class="order-item-name">Product #<%= item.getProductId() %></p>
              <p class="order-item-meta">
                Qty: <%= item.getQuantity() %> &nbsp;·&nbsp;
                &#8377;<%= String.format("%.0f", item.getPrice()) %> each
              </p>
            </div>
            <p class="order-item-price">
              &#8377;<%= String.format("%.0f", item.getPrice() * item.getQuantity()) %>
            </p>
          </div>
        <% } %>
      <% } else { %>
        <p style="color:var(--muted);font-size:13px;">No items found for this order.</p>
      <% } %>
    </div>

    <!-- Right: summary -->
    <div class="detail-summary">

      <!-- Order summary -->
      <div class="summary-card">
        <p class="summary-card-title">Order Summary</p>

        <div class="summary-row">
          <span>Order ID</span>
          <span>#<%= order.getId() %></span>
        </div>
        <div class="summary-row">
          <span>Date</span>
          <span><%= sdf.format(order.getOrderDate()) %></span>
        </div>
        <div class="summary-row">
          <span>Status</span>
          <span class="order-status <%= statusClass %>"><%= order.getStatus() %></span>
        </div>
        <div class="summary-row total">
          <span>Total</span>
          <span>&#8377;<%= String.format("%.0f", order.getTotalAmount()) %></span>
        </div>
      </div>

      <!-- Delivery address -->
      <div class="summary-card">
        <p class="summary-card-title">Delivery Address</p>

        <div class="info-row">
          <span class="info-label">Name</span>
          <span class="info-value"><%= user.getName() %></span>
        </div>
        <% if (user.getAddressLine() != null && !user.getAddressLine().isEmpty()) { %>
          <div class="info-row">
            <span class="info-label">Address</span>
            <span class="info-value"><%= user.getAddressLine() %></span>
          </div>
        <% } %>
        <% if (user.getCity() != null && !user.getCity().isEmpty()) { %>
          <div class="info-row">
            <span class="info-label">City</span>
            <span class="info-value"><%= user.getCity() %>, <%= user.getState() %> — <%= user.getPincode() %></span>
          </div>
        <% } %>
      </div>

      <a href="${pageContext.request.contextPath}/order?action=myOrders"
         class="btn-back">
        &#8592; &nbsp;Back to Orders
      </a>

    </div>
  </div>

  <footer class="site-footer">
    <div class="footer-logo">FASHION<span>.</span></div>
    <p class="footer-note">&copy; 2025 FashionStore. All rights reserved.</p>
  </footer>

</div>
</body>
</html>
