import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { NavbarComponent } from '../../components/navbar/navbar.component';
import { SharedService } from '../../services/shared.service';
import { WishlistService } from '../../services/wishlist.service';
import { CartService } from '../../services/cart.service';
import { ProductService } from '../../services/product.service';
import { Router } from '@angular/router';
import { ChangeDetectorRef } from '@angular/core';
declare var bootstrap: any;

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, NavbarComponent],
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements OnInit {

  categories = [
    { name: 'Mobiles', image: 'https://img.freepik.com/premium-photo/row-smartphones-display-store-showcasing-various-colors-designs_14117-745595.jpg' },
    { name: 'Women', image: 'https://img.freepik.com/free-photo/woman-pink-jacket-looking-camera_23-2148316471.jpg?semt=ais_incoming&w=740&q=80' },
    { name: 'Men', image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT87M04zA2dx2J8VZqXlXajQ5LhsXCn_e_KQQ&s' },
    { name: 'Electronics', image: 'https://t4.ftcdn.net/jpg/03/64/41/07/360_F_364410756_Ev3WoDfNyxO9c9n4tYIsU5YBQWAP3UF8.jpg' },
    { name: 'Fashion', image: 'https://img.freepik.com/free-photo/woman-shopping-clothes-store_23-2148817136.jpg' },
    { name: 'Kids', image: 'https://img.freepik.com/free-photo/little-boy-posing-studio_23-2148445671.jpg' },
    { name: 'Grocery', image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvrkqjdLrFUoY8LWznWqLy2vHIPdBfmgAvuA&s' },
    { name: 'Books', image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRbvAjuhRJUomZiT3NL4gW_vdPmKr1KE7bzmA&s' },
    { name: 'Beauty', image: 'https://img.freepik.com/free-photo/makeup-products-arrangement-top-view_23-2149096665.jpg' },
    { name: 'Food', image: 'https://media.istockphoto.com/id/1457433817/photo/group-of-healthy-food-for-flexitarian-diet.jpg?b=1&s=612x612&w=0&k=20&c=V8oaDpP3mx6rUpRfrt2L9mZCD0_ySlnI7cd4nkgGAb8=' },
    { name: 'Flight Booking', image: 'https://www.shutterstock.com/image-vector/airline-tickets-web-banner-plane-260nw-1850211745.jpg' }
  ];

  categoryMap: any = {
    'Mobiles': 1,
    'Women': 2,
    'Men': 3,
    'Electronics': 4,
    'Fashion': 5,
    'Kids': 6,
    'Grocery': 7,
    'Books': 8,
    'Beauty': 9,
    'Food': 10,
    'Flight Booking': 11
  };

  carouselImages: string[] = [
    'https://shopnearn.in/images/2.jpg',
    'https://cdn.dribbble.com/userupload/16309846/file/original.png'
  ];
  allProducts: any[] = [];
  products: any[] = [];
  filteredProducts: any[] = [];
  showCarousel = true;
  searchQuery = '';
  currentModalProduct: any = null;
  selectedCategory: string = '';
  constructor(
    private http: HttpClient,
    private shared: SharedService,
    private wishlistService: WishlistService,
    private productService: ProductService,
    private cartService: CartService,
    private router: Router,
    private cd: ChangeDetectorRef  
  ) { }

  ngOnInit() {

    // ✅ Load ALL products
    this.productService.getProducts().subscribe({
      next: (res: any[]) => {

        this.allProducts = res.map(p => ({
          id: p.id,
          name: p.name,
          price: p.price,
          image: p.image || 'https://dummyimage.com/300x300/cccccc/000000&text=No+Image',
          description: p.description,
          quantity: 1
        }));

        this.products = [...this.allProducts];
        this.filteredProducts = [...this.allProducts];
      }
    });

    // ✅ LISTEN SEARCH FROM NAVBAR
    this.shared.search$.subscribe((query: string) => {

      const q = query?.toLowerCase().trim();

      if (!q) {
        this.filteredProducts = [...this.products];
        this.showCarousel = true;
        return;
      }

      this.showCarousel = false;

      // 🔥 CALL API FOR GLOBAL SEARCH (BEST PRACTICE)
      this.http.get<any[]>(`http://localhost:5112/api/pro/search/${q}`)
        .subscribe({
          next: (res: any[]) => {

            if (!res || res.length === 0) {
              this.filteredProducts = [];
              return;
            }

            this.filteredProducts = res.map(p => ({
              id: p.id,
              name: p.name,
              price: p.price,
              image: p.image || 'https://dummyimage.com/300x300/cccccc/000000&text=No+Image',
              description: p.description,
              quantity: 1
            }));

          },
          error: () => {
            console.error("Search API error");
            this.filteredProducts = [];
          }
        });
    });

    this.wishlistService.loadWishlist();
  }
  buyNow(product: any) {

    const mappedProduct = {
      id: product.id,
      name: product.name,
      price: product.price,
      image: product.image,
      description: product.description
    };

    localStorage.setItem('buyNowProduct', JSON.stringify(mappedProduct));

    this.router.navigate(['/order']); // ✅ go to order page
  }

  // Category click
  selectCategory(name: string) {
    this.router.navigate(['/products'], {
      queryParams: { category: name }
    });
  }
  // Search
  

  // Image fallback
  onImageError(event: any) {
    event.target.src = 'https://dummyimage.com/300x300/cccccc/000000&text=No+Image';
  }

  // Add to cart
  addToCart(p: any) {
    const user = JSON.parse(localStorage.getItem('user') || 'null');
    if (!user) {
      alert("Please login first");
      return;
    }
    if (!p || !p.id) {
      console.error("Invalid product", p);
      return;
    }
    this.cartService.addToCart(p.id).subscribe({
      next: () => {
        alert(`${p.name} added to cart`);
        this.shared.refreshCart();
      },
      error: (err) => {
        console.error("Cart error:", err);
        alert("Cart failed");
      }
    });
  }

  // Wishlist
  toggleWishlist(p: any) {
    this.wishlistService.toggle(p);
  }

  isInWishlist(p: any) {
    return this.wishlistService.isInWishlist(p);
  }

  // Modal
  openModal(p: any) {
    this.currentModalProduct = p;
    const modal = new bootstrap.Modal(document.getElementById('productModal'));
    modal.show();
  } ngAfterViewInit() {
    setTimeout(() => {
      window.dispatchEvent(new Event('resize'));
    }, 300);
  }

  addModalToCart() {
    if (this.currentModalProduct) {
      this.addToCart(this.currentModalProduct);
    }
  }
  
}
