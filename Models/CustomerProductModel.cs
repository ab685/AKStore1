using System;
using System.ComponentModel.DataAnnotations;

namespace AKStore.Models
{
    public class CustomerProductModel
    {
        public int Id { get; set; }

        [Required]
        public int ProductId { get; set; }

        [Required]
        public int CustomerId { get; set; }

        [Required]
        [Range(1,1000000,ErrorMessage ="Please enter valid quantity")]
        public decimal? Quantity { get; set; }
      
        public DateTime? OrderDate { get; set; }
    }

}
