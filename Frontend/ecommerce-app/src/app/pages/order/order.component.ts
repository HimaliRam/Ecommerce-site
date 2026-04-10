import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { OrderService } from '../../services/order.service';

@Component({
  selector: 'app-order',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './order.component.html',
  styleUrls: ['./order.component.css']
})
export class OrderComponent implements OnInit {

  product: any;
  quantity: number = 1;
  total: number = 0;
  userId = 1;
  products: any[] = [];


  constructor(
    private orderService: OrderService,
    private router: Router
  ) { }

  ngOnInit() {
    const user = JSON.parse(localStorage.getItem('user')!);

    if (!user) {
      alert('Please login first');
      this.router.navigate(['/login']);
      return;
    }

    this.userId = user.id;

    // 🔥 1. GET DATA FROM ROUTER STATE (BEST WAY)
    const nav = this.router.getCurrentNavigation();
    const stateData = nav?.extras?.state?.['cartItems'];

    if (stateData && stateData.length > 0) {
      console.log("Received from router:", stateData);
      this.products = stateData;
      return;
    }

    // 🔥 2. FALLBACK (localStorage)
    const cartData = localStorage.getItem('cartCheckout');

    if (cartData) {
      this.products = JSON.parse(cartData);
      return;
    }

    // 🔥 3. BUY NOW
    const buyNowData = localStorage.getItem('buyNowProduct');

    if (buyNowData) {
      const p = JSON.parse(buyNowData);
      this.products = [{ ...p, quantity: 1 }];
      return;
    }

    // ❌ NOTHING FOUND
    alert('No product found');
    this.router.navigate(['/home']);
  }

  getTotal() {
    return this.products.reduce((t, i) =>
      t + i.price * i.quantity, 0);
  }

  increaseQty(item: any) {
    item.quantity++;
  }

  decreaseQty(item: any) {
    if (item.quantity > 1) {
      item.quantity--;
    }
  }

  calculateTotal() {
    this.total = this.product.price * this.quantity;
  }

  placeOrder() {

    const requests = this.products.map(item => {
      return this.orderService.placeOrder({
        userId: this.userId,
        productId: item.productId || item.id,
        quantity: item.quantity
      });
    });

    Promise.all(requests.map(r => r.toPromise()))
      .then(() => {
        alert('Order Placed Successfully 🎉');

        localStorage.removeItem('cartCheckout');
        localStorage.removeItem('buyNowProduct');

        this.router.navigate(['/orders']);
      })
      .catch(err => {
        console.error(err);
        alert('Order failed');
      });
  
}
}
