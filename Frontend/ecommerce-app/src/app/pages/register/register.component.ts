import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent {

  name = '';
  email = '';
  password = '';
  confirmPassword = '';

  constructor(private authService: AuthService, private router: Router) { }

  register() {

    // ✅ VALIDATION
    if (!this.name || !this.email || !this.password || !this.confirmPassword) {
      alert('Please fill all fields');
      return;
    }

    if (this.password !== this.confirmPassword) {
      alert('Passwords do not match');
      return;
    }

    // ✅ API CALL
    this.authService.register({
      name: this.name,
      email: this.email,
      password: this.password
    }).subscribe({

      next: (res: any) => {

        if (res.message === 'USER_EXISTS') {
          alert('Email already exists!');
        } else {
          alert('Registration successful!');
          this.router.navigate(['/login']);
        }
      },

      error: (err) => {
        console.error(err);
        alert('Something went wrong!');
      }
    });
  }

  goToLogin(event: Event) {
    event.preventDefault();
    this.router.navigate(['/login']);
  }
}
