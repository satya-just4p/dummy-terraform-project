import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from '../../environments/environment';
import { DummyTableModule } from '../model/dummy-table/dummy-table.module';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class UsersService {
  private baseApiUrl : string = environment.baseApiUrl;

  constructor(private http:HttpClient) { }

  // adding user record in the database
  addDummyUserRequest(addDummyUserRequest:DummyTableModule):Observable<DummyTableModule>{
    return this.http.post<DummyTableModule>(this.baseApiUrl + '/api/dummy/addDummyUser',addDummyUserRequest)
  }

  // getting all the users from the database
  getAllUsers():Observable<DummyTableModule[]>{
    return this.http.get<DummyTableModule[]>(this.baseApiUrl + '/api/dummy/getAllDummyUsers');
  }
}
