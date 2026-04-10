import { Routes } from '@angular/router';

import { HomeComponent } from './pages/home/home.component';
import { CartComponent } from './pages/cart/cart.component';
import { LoginComponent } from './pages/login/login.component';
import { RegisterComponent } from './pages/register/register.component';
// NEW - correct
import { ProductComponent } from './pages/products/products.component';
import { WishlistComponent } from './pages/wishlist/wishlist.component';
import { OrderComponent } from './pages/order/order.component';
import { OrderHistoryComponent } from './pages/order/order-history.component';
import { MainComponent } from './pages/main/main.component';



export const routes: Routes = [
  { path: '', redirectTo: 'home', pathMatch: 'full' }, // default
  { path: 'main', component: MainComponent },
  { path: 'home', component: HomeComponent },   // your current page
  { path: 'cart', component: CartComponent },
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
  { path: 'products', component: ProductComponent },
  { path: 'wishlist', component: WishlistComponent },
  { path: 'order', component: OrderComponent },         // Buy Now page
  { path: 'orders', component: OrderHistoryComponent } , // Order history page
   { path: '**', redirectTo: 'home' } // fallback
  ];
