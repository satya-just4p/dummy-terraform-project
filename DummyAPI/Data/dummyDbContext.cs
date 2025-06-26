using DummyAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace DummyAPI.Data
{
	public class dummyDbContext:DbContext
	{
		public dummyDbContext(DbContextOptions options):base(options)
		{
			
		}
		public DbSet<dummyTable> dummyTable { get; set; }
	}
}
