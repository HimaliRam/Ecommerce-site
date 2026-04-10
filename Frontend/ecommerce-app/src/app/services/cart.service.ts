import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs'; // ✅ IMPORTANT

@Injectable({
  providedIn: 'root'
})
export class CartService {

  private baseUrl = 'http://localhost:5112/api/cart';

  constructor(private http: HttpClient) { }

  getUser() {
    return JSON.parse(localStorage.getItem('user') || 'null');
  }

  // ✅ FIXED
  getCart(): Observable<any[]> {
    const user = this.getUser();

    if (!user || !user.id) {
      console.error("User not found");
      return of([]); // ✅ return empty observable instead of http.get([])
    }

    return this.http.get<any[]>(`${this.baseUrl}/${user.id}`);
  }

  // ✅ FIXED
  addToCart(productId: number): Observable<any> {
    const user = this.getUser();

    if (!user || !user.id) {
      alert("Login required");
      return of(null);
    }

    return this.http.post(`${this.baseUrl}/add`, {
      UserId: user.id,
      ProductId: productId,
      Quantity: 1
    });
  }

  // ✅ FIXED
  updateQty(cartId: number, qty: number) {
    return this.http.put(`${this.baseUrl}/update`, {
      CartId: cartId,     // ✅ FIX (capital C)
      Quantity: qty       // ✅ FIX
    });
  }
  // ✅ FIXED
  removeItem(cartId: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/${cartId}`);
  }
}
