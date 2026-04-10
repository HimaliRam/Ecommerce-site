import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { SharedService } from '../../services/shared.service';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.css']
})
export class NavbarComponent {
  searchText = '';
  cartCount = 0;
  isDropdownOpen = false;
  user: any = null;
  userInitial: string = '';
  searchQuery: string = '';

  constructor(private shared: SharedService, private router: Router) { }

  ngOnInit() {
    // Subscribe to cart count updates
    this.shared.cartCount$.subscribe(count => {
      this.cartCount = count;
    });

    // Get user from localStorage
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      this.user = JSON.parse(storedUser);
      this.userInitial = this.user.name ? this.user.name.charAt(0).toUpperCase() : 'U';
    }
  }

  onSearch() {
    const query = this.searchQuery?.trim();
    this.shared.setSearch(query);
    this.router.navigate(['/']);
  }

  logout() {
    // Remove user data
    localStorage.removeItem('user');
    this.user = null;
    this.userInitial = '';
    this.isDropdownOpen = false;

    // ✅ Navigate to login page after logout
    this.router.navigate(['/login']);
  }

  toggleDropdown() {
    this.isDropdownOpen = !this.isDropdownOpen;
  }
}
