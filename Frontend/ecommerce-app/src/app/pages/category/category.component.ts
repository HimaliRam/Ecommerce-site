import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-category',
  standalone: true,
  imports: [CommonModule],
  template: `
    <h2 *ngIf="categoryName">{{ categoryName }} Products</h2>
    <div *ngIf="products.length; else noProducts" class="products">
      <div *ngFor="let p of products" class="product-card">
        <img [src]="p.image" (error)="onImageError($event)" width="200" height="200" style="object-fit: cover;">
        <h3>{{ p.name }}</h3>
        <p>₹{{ p.price }}</p>
      </div>
    </div>
    <ng-template #noProducts>
      <p>No products found in this category.</p>
    </ng-template>
  `,
  styles: [`
    .products { display: flex; flex-wrap: wrap; gap: 1rem; }
    .product-card { width: 200px; border: 1px solid #ccc; padding: 1rem; text-align: center; }
    img { width: 100%; height: auto; }
  `]
})
export class CategoryComponent implements OnInit {

  categoryName: string = '';
  products: any[] = [];
  categoryMap: any = { 'Mobiles': 1, 'Women': 2, 'Men': 3 };

  constructor(private route: ActivatedRoute, private http: HttpClient) { }

  ngOnInit(): void {
    this.categoryName = this.route.snapshot.paramMap.get('name') || '';
    const categoryId = this.categoryMap[this.categoryName];

    if (!categoryId) return;

    this.http.get<any[]>(`http://localhost:5112/api/pro/by-category/${categoryId}`)
      .subscribe({
        next: res => {
          console.log('API Response:', res);

          // 🔹 Fallback if API returns empty
          this.products = (res && res.length > 0 ? res : [
            { id: 1, name: "Test Product 1", price: 999, image: '', description: 'Dummy product' },
            { id: 2, name: "Test Product 2", price: 499, image: '', description: 'Dummy product' }
          ]).map(p => ({
            ...p,
            image: p.image || 'https://dummyimage.com/300x300/cccccc/000000&text=No+Image'
          }));
        },
        error: err => {
          console.error('Category load error', err);
          // 🔹 Show fallback products on error
          this.products = [
            { id: 1, name: "Test Product 1", price: 999, image: '', description: 'Dummy product' },
            { id: 2, name: "Test Product 2", price: 499, image: '', description: 'Dummy product' }
          ].map(p => ({ ...p, image: 'https://dummyimage.com/300x300/cccccc/000000&text=No+Image' }));
        }
      });
  }

  onImageError(event: any) {
    event.target.src = 'https://dummyimage.com/300x300/cccccc/000000&text=No+Image';
  }
}
