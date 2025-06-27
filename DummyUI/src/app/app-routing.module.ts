import { NgModule, ɵNOT_FOUND_CHECK_ONLY_ELEMENT_INJECTOR } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AddUserComponent } from './components/add-user/add-user.component';
import { ListUsersComponent } from './components/list-users/list-users.component';

const routes: Routes = [
  {
    path:'',
  redirectTo : 'list-users', pathMatch: 'full'

  },
  {
    path:'add-user',
    component:AddUserComponent
  },
  {
    path:'list-users',
    component:ListUsersComponent
  }
  
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
