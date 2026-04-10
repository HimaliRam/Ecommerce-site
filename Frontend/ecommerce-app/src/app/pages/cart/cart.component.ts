import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CartService } from '../../services/cart.service';
import { SharedService } from '../../services/shared.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-cart',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './cart.component.html',
  styleUrls: ['./cart.component.css']
})
export class CartComponent implements OnInit {

  cart: any[] = [];

  constructor(
    private cartService: CartService,
    private shared: SharedService,
    private router: Router  ,
    private cdr: ChangeDetectorRef // 🔥 IMPORTANT
  ) { }

  ngOnInit() {
    this.loadCart();

    this.shared.cartRefresh$.subscribe(() => {
      console.log("Cart refresh triggered");

      setTimeout(() => {
        this.loadCart();
      }, 300); // 🔥 wait for backend update
    });
  }
  loadCart() {
    this.cartService.getCart().subscribe({
      next: (res: any[]) => {

        console.log("RAW API:", res);

        const mapped = (res || []).map(item => ({
          id: item.id,
          productId: item.productId,
          name: item.name,
          price: item.price,
          image: item.image,
          quantity: item.quantity ?? item.qty ?? item.Quantity ?? 1
        }));

        // 🔥 IMPORTANT FIX: newest first
        this.cart = mapped.reverse();

        console.log("FINAL CART (NEW FIRST):", this.cart);

        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error("CART ERROR:", err);
        this.cart = [];
      }
    });
  }
  proceedToCheckout() {
    if (this.cart.length === 0) {
      alert("Cart is empty!");
      return;
    }

    // ✅ Backup storage
    localStorage.setItem('cartCheckout', JSON.stringify(this.cart));

    // ✅ Main data via router
    this.router.navigate(['/order'], {
      state: { cartItems: this.cart }
    });
  }
  trackById(index: number, item: any) {
    return item.id;
  }

  increaseQty(item: any) {
    const newQty = (item.quantity || 1) + 1;

    this.cartService.updateQty(item.id, newQty).subscribe({
      next: () => this.loadCart(),
      error: (err) => console.error(err)
    });
  }

  decreaseQty(item: any) {
    const currentQty = item.quantity || 1;

    if (currentQty > 1) {
      this.cartService.updateQty(item.id, currentQty - 1).subscribe({
        next: () => this.loadCart(),
        error: (err) => console.error(err)
      });
    }
  }
  removeItem(item: any) {
    this.cartService.removeItem(item.id).subscribe({
      next: () => this.loadCart(),
      error: (err) => console.error(err)
    });
  }

  getTotal() {
    return this.cart.reduce((total, item) =>
      total + (item.price || 0) * (item.quantity || 1), 0);
  }
}
