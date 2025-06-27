import { Component } from '@angular/core';
import { DummyTableModule } from '../../model/dummy-table/dummy-table.module';
import { Router } from '@angular/router';
import { UsersService } from '../../service/users.service';

@Component({
  selector: 'app-add-user',
  standalone: false,
  templateUrl: './add-user.component.html',
  styleUrl: './add-user.component.css'
})
export class AddUserComponent {

dummyTable : DummyTableModule = {
  id:'',
  name:''
};

constructor(private router : Router, private usersService:UsersService){}

addUserRequest():void{
  this.dummyTable.id = "7c5848df-efe6-40e2-a4ab-76d8ca5b81fd";
  this.usersService.addDummyUserRequest(this.dummyTable).subscribe({

    next:(response) =>{
      if(response){
        this.router.navigate(['/list-users']);
        alert("Record added");
      }
    },
    error:(err) =>{
      alert("Something went wrong");
      return;
    }

  });

}
}
