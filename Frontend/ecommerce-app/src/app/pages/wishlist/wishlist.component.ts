import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { WishlistService } from '../../services/wishlist.service';
import { CartService } from '../../services/cart.service';
import { SharedService } from '../../services/shared.service';
import { ChangeDetectorRef } from '@angular/core';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-wishlist',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './wishlist.component.html',
  styleUrls: ['./wishlist.component.css']
})
export class WishlistComponent implements OnInit, OnDestroy {

  wishlist: any[] = [];
  private sub!: Subscription;

  constructor(
    private wishlistService: WishlistService,
    private cartService: CartService,
    private cdr: ChangeDetectorRef,
    private shared: SharedService
  ) { }

  ngOnInit() {
    // 🔥 Load wishlist
    this.wishlistService.loadWishlist();

    // 🔥 Subscribe to wishlist changes
    this.sub = this.wishlistService.wishlist$.subscribe(res => {

      const list = res || [];

      // 🔥 NEW FIX: show latest first
      this.wishlist = [...list].reverse();

      this.cdr.detectChanges();
    });
  }

  // 🔥 ADD TO CART
  addToCart(item: any) {
    const productId = item.productId || item.id; // 🔥 FIX

    if (!productId) {
      alert('Invalid product ❌');
      return;
    }

    this.cartService.addToCart(productId).subscribe({
      next: () => {
        alert('Added to cart ✅');
        this.cdr.detectChanges();
        // ❌ DO NOT REMOVE FROM WISHLIST
        // this.wishlistService.remove(item);

        // 🔥 FORCE RELOAD CART AFTER API DELAY
        setTimeout(() => {
          this.shared.triggerCartRefresh();
        }, 300);
      },
      error: (err) => {
        console.error(err);
        alert('Failed to add to cart ❌');
      }
    });
  }
  // 🔥 REMOVE ITEM
  removeItem(item: any) {
    this.wishlistService.remove(item);
  }

  // 🔥 CLEANUP (IMPORTANT)
  ngOnDestroy() {
    if (this.sub) {
      this.sub.unsubscribe();
    }
  }
}
