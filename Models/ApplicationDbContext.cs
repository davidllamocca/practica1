using Microsoft.EntityFrameworkCore;

namespace practica1.Models
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options) 
        {
        }

        public DbSet<ProductoCredito> ProductosCredito { get; set; }
    }
}

