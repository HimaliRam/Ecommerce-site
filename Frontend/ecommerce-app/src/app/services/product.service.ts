import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class ProductService {

  private apiUrl = 'http://localhost:5112/api/product';

  constructor(private http: HttpClient) { }

  getProducts() {
    return this.http.get<any[]>(this.apiUrl);
  }
}
