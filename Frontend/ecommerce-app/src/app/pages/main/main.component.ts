import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-main',
  standalone: true,
  templateUrl: './main.component.html',
  styleUrls: ['./main.component.css']
})
export class MainComponent {

  constructor(private router: Router) { }

  goToHome() {
    this.router.navigate(['/home']);   // View Products
  }

  goToLogin() {
    this.router.navigate(['/login']);  // Login page
  }
}
