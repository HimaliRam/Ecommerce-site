import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class WishlistService {

  private wishlistSubject = new BehaviorSubject<any[]>([]);
  wishlist$ = this.wishlistSubject.asObservable();

  constructor(private http: HttpClient) { }

  private getUser() {
    return JSON.parse(localStorage.getItem('user') || 'null');
  }

  // ✅ LOAD FROM DB
  loadWishlist() {
    const user = this.getUser();
    if (!user) return;

    this.http.get<any[]>(`http://localhost:5112/api/wishlist/${user.id}`)
      .subscribe(res => {
        this.wishlistSubject.next(res || []);
      });
  }

  // ✅ ADD (🔥 instant UI update)
  add(item: any) {
    const user = this.getUser();
    if (!user) return;

    // 🔥 update UI immediately
    const current = this.wishlistSubject.value;
    this.wishlistSubject.next([...current, { ...item, productId: item.id }]);

    // 🔥 API call
    this.http.post(
      `http://localhost:5112/api/wishlist/add?userId=${user.id}&productId=${item.id}`,
      {}
    ).subscribe();
  }

  // ✅ REMOVE (🔥 instant UI update)
  remove(item: any) {
    const user = this.getUser();
    if (!user) return;

    const current = this.wishlistSubject.value;
    const updated = current.filter(x => x.productId !== (item.productId || item.id));

    // 🔥 update UI immediately
    this.wishlistSubject.next(updated);

    // 🔥 API call
    this.http.delete(
      `http://localhost:5112/api/wishlist/remove?userId=${user.id}&productId=${item.productId || item.id}`
    ).subscribe();
  }

  // ✅ TOGGLE (NO CHANGE NEEDED)
  toggle(item: any) {
    const exists = this.isInWishlist(item);

    if (exists) {
      this.remove(item);
    } else {
      this.add(item);
    }
  }

  // ✅ FIXED CHECK
  isInWishlist(item: any): boolean {

    if (!item) return false;

    return this.wishlistSubject.value.some((x: any) =>
      (x.productId || x.id) === (item.id || item.productId)
    );
  }
}
