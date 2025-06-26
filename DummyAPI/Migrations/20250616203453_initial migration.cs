using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DummyAPI.Migrations
{
    /// <inheritdoc />
    public partial class initialmigration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "dummyTable",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    name = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_dummyTable", x => x.id);
                });
            migrationBuilder.Sql(@"
            ALTER AUTHORIZATION ON DATABASE::dummydb TO [dummy];

            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "dummyTable");
        }
    }
}
