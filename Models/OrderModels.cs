using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace AKStore.Models
{
    public class OrderModels
    {
        public int Id { get; set; }

        [Required]
        public int? ProductId { get; set; }
        [Required]
        public int? DistributorId { get; set; } 
        public int? OrderStatusId { get; set; }

        [Required]
        public int? CustomerId { get; set; }

        public string ProductName { get; set; }

        public string CustomerName { get; set; }
        public int SerialNo { get; set; }


        [Required]
        public int? Quantity { get; set; }

        [Required]
        public decimal? Price { get; set; }

        public decimal? Total { get; set; }
        public DateTime? OrderDate { get; set; }
        public string FilePath { get; set; }
        public bool? IsActive { get; set; }

    }

}
