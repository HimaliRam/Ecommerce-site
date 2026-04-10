import { Injectable } from '@angular/core';
import { BehaviorSubject, Subject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SharedService {

  // ================= CART COUNT =================
  private cartCountSource = new BehaviorSubject<number>(0);
  cartCount$ = this.cartCountSource.asObservable();

  // ================= SEARCH =================
  private searchSource = new BehaviorSubject<string>('');
  search$ = this.searchSource.asObservable();

  // ================= CART REFRESH =================
  private cartRefreshSource = new Subject<void>();
  cartRefresh$ = this.cartRefreshSource.asObservable();

  constructor() {
    this.loadCartCount();
  }

  // ================= CART METHODS =================
  loadCartCount() {
    this.cartCountSource.next(this.getCartCount());
  }

  addToCart(p: any) {
    let cart = JSON.parse(localStorage.getItem('cart') || '[]');

    const existing = cart.find((x: any) => x.name === p.name);

    if (existing) {
      existing.qty++;
    } else {
      cart.push({ ...p, qty: 1 });
    }

    localStorage.setItem('cart', JSON.stringify(cart));

    this.cartCountSource.next(this.getCartCount());

    // 🔥 AUTO REFRESH TRIGGER
    this.triggerCartRefresh();
  }

  getCartCount(): number {
    let cart = JSON.parse(localStorage.getItem('cart') || '[]');
    return cart.reduce((acc: number, item: any) => acc + item.qty, 0);
  }

  // ================= SEARCH =================
  setSearch(query: string) {
    this.searchSource.next(query);
  }

  // ================= REFRESH METHODS =================
  triggerCartRefresh() {
    this.cartRefreshSource.next();

    // 🔥 ALSO UPDATE COUNT
    this.loadCartCount();
  }

  // (optional backward compatibility)
  refreshCart() {
    this.triggerCartRefresh();
  }
}
