import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { OrderService } from '../../services/order.service';
import { Router } from '@angular/router';
import { ChangeDetectorRef } from '@angular/core';


interface OrderItem {
  productId: number;
  name: string;
  imageUrl: string;
  quantity: number;
  price: number;
}

interface Order {
  id: number;
  orderDate: string;
  totalAmount: number;
  items: OrderItem[];
}

@Component({
  selector: 'app-order-history',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './order-history.component.html',
  styleUrls: ['./order-history.component.css']
})
export class OrderHistoryComponent implements OnInit {

  orders: any[] = [];
  userId = 1;
  loading = true;

  constructor(
    private orderService: OrderService,
    private cd: ChangeDetectorRef,
    private router: Router
  ) { }

  ngOnInit() {
    const user = JSON.parse(localStorage.getItem('user')!);

    if (!user) {
      alert('Please login first');
      this.router.navigate(['/login']);
      return;
    }

    this.userId = user.id; // ✅ IMPORTANT

    this.loadOrders();
  }

  loadOrders() {
    this.loading = true;

    this.orderService.getOrders(this.userId).subscribe({
      next: (res: Order[]) => {   
        this.orders = [];

        res.forEach(order => {
          order.items.forEach(item => {
            this.orders.push({
              name: item.name,
              price: item.price,
              quantity: item.quantity,
              image: item.imageUrl || 'assets/no-image.png',
              orderDate: order.orderDate
            });
          });
        });

        this.loading = false;
        this.cd.detectChanges();
      },
      error: (err) => {
        console.error(err);
        this.orders = [];
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }
}
