import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { WishlistService } from '../../services/wishlist.service';
import { FormsModule } from '@angular/forms';
import { ChangeDetectorRef } from '@angular/core';
import { CartService } from '../../services/cart.service';
import { SharedService } from '../../services/shared.service';

@Component({
  selector: 'app-product',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './products.component.html',
  styleUrls: ['./products.component.css']
})
export class ProductComponent implements OnInit {

  products: any[] = [];
  filteredProducts: any[] = [];

  selectedCategory: string = '';
  selectedPriceFilter: string = '';
  selectedSort: string = '';

  categoryMap: any = {
    Mobiles: 1,
    Women: 2,
    Men: 3,
    Electronics: 4,
    Fashion: 5,
    Kids: 6,
    Grocery: 7,
    Books: 8,
    Beauty: 9,
    Food: 10,
    'Flight Booking': 11
  };

  constructor(
    private route: ActivatedRoute,
    private http: HttpClient,
    private wishlistService: WishlistService,
    private router: Router,
    private cd: ChangeDetectorRef,
    private cartService: CartService,   // ✅ ADD THIS
    private shared: SharedService       // ✅ ADD THIS
  ) { }

  ngOnInit() {

    this.route.queryParams.subscribe(params => {

      // ✅ CLEAN CATEGORY
      this.selectedCategory = decodeURIComponent(params['category'] || '').trim();
      console.log("CATEGORY:", this.selectedCategory);

      const categoryId = this.categoryMap[this.selectedCategory];

      console.log("CATEGORY ID:", categoryId);

      if (!categoryId) {
        this.products = [];
        this.filteredProducts = [];
        return;
      }

      this.loadProducts(categoryId);
    });
  }

  loadProducts(categoryId: number) {

    this.http.get<any[]>(`http://localhost:5112/api/pro/by-category/${categoryId}`)
      .subscribe({
        next: (res) => {

          console.log("API DATA:", res);

          this.products = (res || []).map(p => ({
            id: p.id,
            name: p.name,
            price: p.price,
            image: p.image || 'https://dummyimage.com/300x300',
            description: p.description
          }));

          this.filteredProducts = [...this.products];

          console.log("PRODUCT COUNT:", this.products.length);

          // 🔥 FORCE UI UPDATE (IMPORTANT FIX)
          this.cd.detectChanges();
        },
        error: (err) => {
          console.error(err);
          this.products = [];
          this.filteredProducts = [];
          this.cd.detectChanges();
        }
      });
  }
  applyPriceFilter() {

    const list = [...this.products];

    if (this.selectedPriceFilter === 'lt100') {
      this.filteredProducts = list.filter(p => p.price < 100);
    }
    else if (this.selectedPriceFilter === '500-1000') {
      this.filteredProducts = list.filter(p => p.price >= 500 && p.price <= 1000);
    }
    else if (this.selectedPriceFilter === 'gt1000') {
      this.filteredProducts = list.filter(p => p.price > 1000);
    }
    else {
      this.filteredProducts = list;
    }
  }
  applyFilters() {

    let list = [...this.products];

    // ================= PRICE FILTER =================
    if (this.selectedPriceFilter === 'lt100') {
      list = list.filter(p => p.price < 100);
    }
    else if (this.selectedPriceFilter === '500-1000') {
      list = list.filter(p => p.price >= 500 && p.price <= 1000);
    }
    else if (this.selectedPriceFilter === 'gt1000') {
      list = list.filter(p => p.price > 1000);
    }

    // ================= SORTING =================
    if (this.selectedSort === 'low-high') {
      list.sort((a, b) => a.price - b.price);
    }
    else if (this.selectedSort === 'high-low') {
      list.sort((a, b) => b.price - a.price);
    }

    this.filteredProducts = list;
  }

  addToCart(p: any) {
    this.cartService.addToCart(p.id).subscribe({
      next: (res) => {
        console.log("Added to cart:", res);

        // 🔥 trigger cart refresh globally
        this.shared.triggerCartRefresh();

        alert(`${p.name} added to cart`);
      },
      error: (err) => {
        console.error("Add to cart failed:", err);
        alert("Failed to add to cart");
      }
    });
  }

  buyNow(product: any) {
    localStorage.setItem('buyNowProduct', JSON.stringify(product));
    this.router.navigate(['/order']);
  }

  toggleWishlist(p: any) {
    this.wishlistService.toggle(p);
  }

  isInWishlist(p: any) {
    return this.wishlistService.isInWishlist(p);
  }
  onImageError(event: any) {
    event.target.src = 'https://dummyimage.com/300x300/cccccc/000000&text=No+Image';
  }
}
