import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Subject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class OrderService {

  private baseUrl = 'http://localhost:5112/api/order';

  // 🔥 NEW: trigger for refresh
  private orderUpdatedSource = new Subject<void>();
  orderUpdated$ = this.orderUpdatedSource.asObservable();

  constructor(private http: HttpClient) { }

  placeOrder(data: any) {
    return this.http.post(`${this.baseUrl}/place`, data);
  }

  getOrders(userId: number) {
    const token = localStorage.getItem('token');

    return this.http.get<any>(`http://localhost:5112/api/order/${userId}`, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });
  }

  // 🔥 call this after order placed
  notifyOrderUpdated() {
    this.orderUpdatedSource.next();
  }
}
