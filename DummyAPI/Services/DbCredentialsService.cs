using Amazon.SimpleSystemsManagement;
using Amazon.SimpleSystemsManagement.Model;
using System.Threading.Tasks;

namespace DummyAPI.Services
{
	public class DbCredentialsService
	{
		private readonly IAmazonSimpleSystemsManagement _ssm;
		public DbCredentialsService()
		{
			_ssm = new AmazonSimpleSystemsManagementClient();
		}

		private async Task<string> Get(string name)
		{
			var response = await _ssm.GetParameterAsync(new GetParameterRequest
			{
				Name = name,
				WithDecryption = true
			});

			return response.Parameter.Value;
		}
		public async Task<string> GetConnectionStringAsync()
		{
			var host = await Get("/rds/host");
			var db = await Get("/rds/name");
			var user = await Get("/rds/username");
			var password = await Get("/rds/password");

			return $"Server={host};database={db};user id={user};password={password};TrustServerCertificate=true;";
		}
	}
}
