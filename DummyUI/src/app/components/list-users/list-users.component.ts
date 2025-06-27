import { Component, OnInit } from '@angular/core';
import { DummyTableModule } from '../../model/dummy-table/dummy-table.module';
import { UsersService } from '../../service/users.service';

@Component({
  selector: 'app-list-users',
  standalone: false,
  templateUrl: './list-users.component.html',
  styleUrl: './list-users.component.css'
})
export class ListUsersComponent implements OnInit {
  dummyTable : DummyTableModule[] = [];

  constructor(private userService:UsersService){}
  ngOnInit(): void {
    this.userService.getAllUsers().subscribe({
      next:(users) => {
               
        this.dummyTable = users;
      },
      error: (err) => {
        console.log("Something went wrong");
      }
      })
  }

}
