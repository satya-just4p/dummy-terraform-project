using DummyAPI.Data;
using DummyAPI.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DummyAPI.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class dummyController : ControllerBase
	{
		private readonly dummyDbContext _dbcontext;
		public dummyController(dummyDbContext dbcontext)
		{
			this._dbcontext = dbcontext;
		}
		[HttpPost("addDummyUser")]
		public async Task<IActionResult> addDummyUser([FromBody] dummyTable _addDummyUserRequest)
		{
			var test = new dummyTable
			{
				id = Guid.NewGuid(),
				name = _addDummyUserRequest.name

			};
			await _dbcontext.dummyTable.AddAsync(test);
			await _dbcontext.SaveChangesAsync();

			return Ok(new {message = "record added!!"});
		}

		[HttpGet("getAllDummyUsers")]
		public async Task<IActionResult> getAllDummyUsers()
		{
			var getAllDummyUsers = await _dbcontext.dummyTable.ToListAsync();
			if(getAllDummyUsers !=null && getAllDummyUsers.Count >0)
			{
				return Ok(getAllDummyUsers);
			}
			else
			{
				return Ok(new {message = "No Record Found"});
			}
		}
	}
}
