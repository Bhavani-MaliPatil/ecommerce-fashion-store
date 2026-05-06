<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.fashionstore.model.Product" %>
<%@ page import="com.fashionstore.model.ProductVariant" %>
<%@ page import="com.fashionstore.model.User" %>

<%
    Product product         = (Product) request.getAttribute("product");
    List<ProductVariant> variants = (List<ProductVariant>) request.getAttribute("variants");
    List<Product> related   = (List<Product>) request.getAttribute("related");
    String categoryName     = (String) request.getAttribute("categoryName");
    User user               = (User) session.getAttribute("user");

    int cartCount = request.getAttribute("cartCount") != null
        ? (int) request.getAttribute("cartCount") : 0;

    boolean hasVariants = variants != null && !variants.isEmpty();
    boolean hasStock    = false;
    if (hasVariants) {
        for (ProductVariant v : variants) {
            if (v.getStock() > 0) { hasStock = true; break; }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= product.getName() %> — FashionStore</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/product-detail.css">
</head>
<body>

<!-- ── Nav ── -->
<nav class="top-nav">
  <a href="${pageContext.request.contextPath}/products" class="nav-logo">FASHION<span>.</span></a>
  <ul class="nav-links">
    <% if (user != null) { %>
      <li><a href="${pageContext.request.contextPath}/user?action=profile"><%= user.getName().split(" ")[0] %></a></li>
      <li><a href="${pageContext.request.contextPath}/order?action=myOrders">Orders</a></li>
      <li>
        <a href="${pageContext.request.contextPath}/cart" class="nav-cart">
          Cart
          <% if (cartCount > 0) { %><span class="nav-cart-badge"><%= cartCount %></span><% } %>
        </a>
      </li>
      <li><a href="${pageContext.request.contextPath}/user?action=logout">Sign out</a></li>
    <% } else { %>
      <li><a href="${pageContext.request.contextPath}/user?action=login">Sign in</a></li>
      <li><a href="${pageContext.request.contextPath}/user?action=register">Register</a></li>
    <% } %>
  </ul>
</nav>

<div class="page-body">

  <!-- ── Breadcrumb ── -->
  <div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/products">All Products</a>
    <span class="breadcrumb-sep">&#8250;</span>
    <a href="${pageContext.request.contextPath}/products?categoryId=<%= product.getCategoryId() %>">
      <%= categoryName %>
    </a>
    <span class="breadcrumb-sep">&#8250;</span>
    <span class="breadcrumb-current"><%= product.getName() %></span>
  </div>

  <!-- ── Product Section ── -->
  <div class="product-section">

    <!-- Image -->
    <div class="product-image-wrap">
      <span class="img-category-tag"><%= categoryName %></span>
      <% if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) { %>
        <img
          src="${pageContext.request.contextPath}<%= product.getImageUrl() %>"
          alt="<%= product.getName() %>"
        >
      <% } else { %>
        <div class="product-image-placeholder">
          <svg width="64" height="64" viewBox="0 0 24 24" fill="none"
               stroke="currentColor" stroke-width="0.8">
            <rect x="3" y="3" width="18" height="18" rx="2"/>
            <circle cx="8.5" cy="8.5" r="1.5"/>
            <polyline points="21,15 16,10 5,21"/>
          </svg>
          <span style="font-size:12px;letter-spacing:1px;margin-top:8px;">No image available</span>
        </div>
      <% } %>
    </div>

    <!-- Info -->
    <div class="product-info">

      <p class="product-info-eyebrow"><%= categoryName %> &nbsp;·&nbsp; FashionStore</p>
      <h1 class="product-info-name"><%= product.getName() %></h1>
      <p class="product-info-price">&#8377;<%= String.format("%.0f", product.getPrice()) %></p>

      <!-- Error alert (add to cart failed) -->
      <% if ("cart".equals(request.getParameter("error"))) { %>
        <div class="alert alert-error">Failed to add to cart. Please try again.</div>
      <% } %>

      <div class="divider"></div>

      <!-- Description -->
      <% if (product.getDescription() != null && !product.getDescription().isEmpty()) { %>
        <p class="product-desc-label">Description</p>
        <p class="product-desc-text"><%= product.getDescription() %></p>
        <div class="divider"></div>
      <% } %>

      <!-- Add to cart form -->
      <% if (user != null) { %>
        <form action="${pageContext.request.contextPath}/product-details" method="post" id="cartForm">
          <input type="hidden" name="productId" value="<%= product.getId() %>">
          <input type="hidden" name="variantId" id="selectedVariantId" value="">

          <!-- Size selector -->
          <% if (hasVariants) { %>
            <div class="size-label">
              Select Size
              <a href="#" class="size-guide-link">Size Guide</a>
            </div>

            <div class="size-grid">
              <% for (ProductVariant v : variants) {
                   boolean outOfStock = v.getStock() <= 0;
                   boolean lowStock   = v.getStock() > 0 && v.getStock() <= 3;
              %>
                <input
                  type="radio"
                  class="size-option <%= outOfStock ? "out-of-stock" : "" %>"
                  name="sizeRadio"
                  id="size_<%= v.getId() %>"
                  value="<%= v.getId() %>"
                  data-stock="<%= v.getStock() %>"
                  <%= outOfStock ? "disabled" : "" %>
                >
                <label for="size_<%= v.getId() %>"><%= v.getSize() %></label>
              <% } %>
            </div>

            <p class="stock-note" id="stockNote">Select a size to check availability</p>

          <% } else { %>
            <p class="stock-note no-stock">No sizes available for this product.</p>
          <% } %>

          <div class="divider"></div>

          <!-- Quantity -->
          <% if (hasStock) { %>
            <p class="qty-label">Quantity</p>
            <div class="qty-control" style="margin-bottom:24px;">
              <button type="button" class="qty-btn" id="qtyMinus">&#8722;</button>
              <input type="number" class="qty-input" name="quantity" id="qtyInput"
                     value="1" min="1" max="10" readonly>
              <button type="button" class="qty-btn" id="qtyPlus">&#43;</button>
            </div>
          <% } %>

          <button
            type="submit"
            class="btn-add-cart"
            id="addCartBtn"
            <%= !hasStock ? "disabled" : "" %>
          >
            <%= hasStock ? "Add to Cart" : "Out of Stock" %>
          </button>

        </form>

      <% } else { %>
        <!-- Not logged in -->
        <div class="divider"></div>
        <a href="${pageContext.request.contextPath}/user?action=login"
           class="btn-add-cart"
           style="display:block;text-align:center;text-decoration:none;padding:16px;">
          Sign in to Add to Cart
        </a>
      <% } %>

      <div class="divider"></div>

      <!-- Product meta -->
      <div class="product-meta">
        <div class="product-meta-row">
          <span class="product-meta-key">Category</span>
          <span class="product-meta-val"><%= categoryName %></span>
        </div>
        <div class="product-meta-row">
          <span class="product-meta-key">Product ID</span>
          <span class="product-meta-val">#<%= product.getId() %></span>
        </div>
        <div class="product-meta-row">
          <span class="product-meta-key">Availability</span>
          <span class="product-meta-val <%= hasStock ? "stock-note in-stock" : "stock-note no-stock" %>">
            <%= hasStock ? "In Stock" : "Out of Stock" %>
          </span>
        </div>
      </div>

    </div>
  </div>

  <!-- ── Related Products ── -->
  <% if (related != null && !related.isEmpty()) { %>
  <div class="related-section">
    <h2 class="related-heading">You May Also Like</h2>
    <p class="related-sub">More from <%= categoryName %></p>

    <div class="related-grid">
      <% for (Product r : related) { %>
        <a href="${pageContext.request.contextPath}/product-details?id=<%= r.getId() %>"
           class="related-card">
          <div class="related-img-wrap">
            <% if (r.getImageUrl() != null && !r.getImageUrl().isEmpty()) { %>
              <img class="related-img"
                   src="${pageContext.request.contextPath}<%= r.getImageUrl() %>"
                   alt="<%= r.getName() %>"
                   loading="lazy">
            <% } else { %>
              <div class="related-img-placeholder">&#9900;</div>
            <% } %>
          </div>
          <div class="related-body">
            <p class="related-tag"><%= categoryName %></p>
            <p class="related-name"><%= r.getName() %></p>
            <p class="related-price">&#8377;<%= String.format("%.0f", r.getPrice()) %></p>
          </div>
        </a>
      <% } %>
    </div>
  </div>
  <% } %>

  <!-- ── Footer ── -->
  <footer class="site-footer">
    <div class="footer-logo">FASHION<span>.</span></div>
    <p class="footer-note">&copy; 2025 FashionStore. All rights reserved.</p>
  </footer>

</div>

<script>
  // ── Size selection → update hidden variantId + stock note
  const sizeRadios  = document.querySelectorAll('.size-option:not(.out-of-stock)');
  const variantInput = document.getElementById('selectedVariantId');
  const stockNote   = document.getElementById('stockNote');
  const addCartBtn  = document.getElementById('addCartBtn');

  sizeRadios.forEach(radio => {
    radio.addEventListener('change', () => {
      const stock = parseInt(radio.dataset.stock);
      variantInput.value = radio.value;

      if (stockNote) {
        if (stock > 10) {
          stockNote.textContent = 'In stock';
          stockNote.className = 'stock-note in-stock';
        } else if (stock > 0) {
          stockNote.textContent = `Only ${stock} left — order soon`;
          stockNote.className = 'stock-note low-stock';
        }
      }

      if (addCartBtn) {
        addCartBtn.disabled = false;
        addCartBtn.textContent = 'Add to Cart';
      }
    });
  });

  // ── Quantity controls
  const qtyInput = document.getElementById('qtyInput');
  const qtyMinus = document.getElementById('qtyMinus');
  const qtyPlus  = document.getElementById('qtyPlus');

  if (qtyMinus && qtyPlus && qtyInput) {
    qtyMinus.addEventListener('click', () => {
      const val = parseInt(qtyInput.value);
      if (val > 1) qtyInput.value = val - 1;
    });

    qtyPlus.addEventListener('click', () => {
      const val = parseInt(qtyInput.value);
      if (val < 10) qtyInput.value = val + 1;
    });
  }

  // ── Form validation — must select a size before submitting
  const cartForm = document.getElementById('cartForm');
  if (cartForm) {
    cartForm.addEventListener('submit', e => {
      if (!variantInput.value) {
        e.preventDefault();
        if (stockNote) {
          stockNote.textContent = 'Please select a size first.';
          stockNote.className = 'stock-note no-stock';
        }
      }
    });
  }
</script>

</body>
</html>
