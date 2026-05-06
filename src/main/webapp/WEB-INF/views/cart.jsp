<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.fashionstore.model.User" %>
<%@ page import="com.fashionstore.model.CartItemView" %>

<%
    List<CartItemView> cartItems = (List<CartItemView>) request.getAttribute("cartItems");
    double totalAmount = request.getAttribute("totalAmount") != null
        ? (double) request.getAttribute("totalAmount") : 0;
    int cartCount = request.getAttribute("cartCount") != null
        ? (int) request.getAttribute("cartCount") : 0;
    User user = (User) session.getAttribute("user");

    boolean isEmpty = cartItems == null || cartItems.isEmpty();

    // Delivery free above ₹999
    double deliveryCharge = totalAmount >= 999 ? 0 : 99;
    double grandTotal     = totalAmount + deliveryCharge;
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Cart — FashionStore</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cart.css">
</head>
<body>

<!-- ── Nav ── -->
<nav class="top-nav">
  <a href="${pageContext.request.contextPath}/products" class="nav-logo">FASHION<span>.</span></a>
  <ul class="nav-links">
    <li><a href="${pageContext.request.contextPath}/products">Shop</a></li>
    <li><a href="${pageContext.request.contextPath}/user?action=profile"><%= user.getName().split(" ")[0] %></a></li>
    <li><a href="${pageContext.request.contextPath}/order?action=myOrders">Orders</a></li>
    <li>
      <a href="${pageContext.request.contextPath}/cart" class="nav-cart active">
        Cart
        <% if (cartCount > 0) { %><span class="nav-cart-badge"><%= cartCount %></span><% } %>
      </a>
    </li>
    <li><a href="${pageContext.request.contextPath}/user?action=logout">Sign out</a></li>
  </ul>
</nav>

<div class="page-body">

  <!-- ── Page Header ── -->
  <div class="page-header">
    <p class="page-eyebrow">Shopping</p>
    <h1 class="page-title">
      My Cart
      <% if (!isEmpty) { %>
        <span style="font-size:20px;color:var(--muted);font-family:'Barlow',sans-serif;font-weight:300;letter-spacing:0;">
          &nbsp;(<%= cartCount %> <%= cartCount == 1 ? "item" : "items" %>)
        </span>
      <% } %>
    </h1>
  </div>

  <div class="cart-layout">

    <% if (!isEmpty) { %>

      <!-- ── Cart Items ── -->
      <div class="cart-items-wrap">

        <!-- Success flash -->
        <% if (request.getAttribute("successMsg") != null) { %>
          <div class="alert alert-success">${successMsg}</div>
        <% } %>

        <% for (CartItemView view : cartItems) { %>
          <div class="cart-item">

            <!-- Image -->
            <div class="cart-item-img-wrap">
              <% if (view.getProduct().getImageUrl() != null && !view.getProduct().getImageUrl().isEmpty()) { %>
                <img class="cart-item-img"
                     src="${pageContext.request.contextPath}<%= view.getProduct().getImageUrl() %>"
                     alt="<%= view.getProduct().getName() %>">
              <% } else { %>
                <div class="cart-item-img-placeholder">&#9900;</div>
              <% } %>
            </div>

            <!-- Details -->
            <div class="cart-item-details">
              <p class="cart-item-category">
                <%= view.getProduct().getCategoryId() == 1 ? "Men" : "Women" %>
              </p>
              <h3 class="cart-item-name"><%= view.getProduct().getName() %></h3>
              <div class="cart-item-meta">
                <span>Size: <%= view.getSize() %></span>
                <span>&#8377;<%= String.format("%.0f", view.getProduct().getPrice()) %> each</span>
              </div>

              <!-- Qty control form -->
              <form action="${pageContext.request.contextPath}/cart"
                    method="post"
                    id="qtyForm_<%= view.getItem().getId() %>"
                    style="display:inline;">
                <input type="hidden" name="action"     value="update">
                <input type="hidden" name="cartItemId" value="<%= view.getItem().getId() %>">
                <input type="hidden" name="quantity"
                       id="qtyHidden_<%= view.getItem().getId() %>"
                       value="<%= view.getItem().getQuantity() %>">
              </form>

              <div class="qty-control">
                <button type="button" class="qty-btn"
                        onclick="changeQty(<%= view.getItem().getId() %>, -1)">&#8722;</button>
                <div class="qty-display" id="qtyDisplay_<%= view.getItem().getId() %>">
                  <%= view.getItem().getQuantity() %>
                </div>
                <button type="button" class="qty-btn"
                        onclick="changeQty(<%= view.getItem().getId() %>, 1)">&#43;</button>
              </div>
            </div>

            <!-- Actions -->
            <div class="cart-item-actions">
              <p class="cart-item-total">
                &#8377;<%= String.format("%.0f", view.getItemTotal()) %>
              </p>

              <!-- Remove form -->
              <form action="${pageContext.request.contextPath}/cart" method="post">
                <input type="hidden" name="action"     value="remove">
                <input type="hidden" name="cartItemId" value="<%= view.getItem().getId() %>">
                <button type="submit" class="btn-remove">Remove</button>
              </form>
            </div>

          </div>
        <% } %>
      </div>

      <!-- ── Order Summary ── -->
      <div class="order-summary">
        <p class="summary-title">Order Summary</p>

        <div class="summary-row">
          <span>Subtotal (<%= cartCount %> items)</span>
          <span>&#8377;<%= String.format("%.0f", totalAmount) %></span>
        </div>

        <div class="summary-row">
          <span>Delivery</span>
          <span>
            <% if (deliveryCharge == 0) { %>
              <span style="color:var(--success);">Free</span>
            <% } else { %>
              &#8377;<%= String.format("%.0f", deliveryCharge) %>
            <% } %>
          </span>
        </div>

        <% if (deliveryCharge > 0) { %>
          <p style="font-size:11px;color:var(--muted);margin-bottom:4px;">
            Add &#8377;<%= String.format("%.0f", 999 - totalAmount) %> more for free delivery
          </p>
        <% } %>

        <div class="summary-row total">
          <span>Total</span>
          <span class="summary-val">&#8377;<%= String.format("%.0f", grandTotal) %></span>
        </div>

        <p class="summary-note">
          Taxes included. Delivery calculated at checkout.
        </p>

        <a href="${pageContext.request.contextPath}/order?action=placeOrder"
           class="btn-checkout">
          Proceed to Checkout
        </a>

        <a href="${pageContext.request.contextPath}/products"
           class="btn-continue">
          Continue Shopping
        </a>
      </div>

    <% } else { %>

      <!-- ── Empty Cart ── -->
      <div class="empty-cart">
        <div class="empty-cart-icon">
          <svg width="80" height="80" viewBox="0 0 24 24" fill="none"
               stroke="currentColor" stroke-width="0.8">
            <path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
            <line x1="3" y1="6" x2="21" y2="6"/>
            <path d="M16 10a4 4 0 01-8 0"/>
          </svg>
        </div>
        <h2>Your cart is empty</h2>
        <p>Looks like you haven't added anything yet. Browse our collection to get started.</p>
        <a href="${pageContext.request.contextPath}/products">Browse Collection</a>
      </div>

    <% } %>

  </div>

  <!-- ── Footer ── -->
  <footer class="site-footer">
    <div class="footer-logo">FASHION<span>.</span></div>
    <p class="footer-note">&copy; 2025 FashionStore. All rights reserved.</p>
  </footer>

</div>

<script>
  // Quantity update — changes display then auto-submits form
  function changeQty(itemId, delta) {
    const display = document.getElementById('qtyDisplay_' + itemId);
    const hidden  = document.getElementById('qtyHidden_'  + itemId);
    const form    = document.getElementById('qtyForm_'    + itemId);

    let current = parseInt(display.textContent);
    let newVal  = current + delta;

    if (newVal < 1)  newVal = 1;
    if (newVal > 10) newVal = 10;

    display.textContent = newVal;
    hidden.value        = newVal;

    // Small delay so user sees the change before submit
    setTimeout(() => form.submit(), 200);
  }
</script>

</body>
</html>
