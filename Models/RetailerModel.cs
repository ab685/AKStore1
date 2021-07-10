using System;
using System.ComponentModel.DataAnnotations;

namespace AKStore.Models
{
    public class RetailerModel
    {
        public int Id { get; set; }
        [Required(AllowEmptyStrings = false)]
        public string Name { get; set; }

        public int UserId { get; set; }
        public int DistributorId { get; set; }
        public DateTime? InsertedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
        [Required(AllowEmptyStrings = false)]
        public string UserName { get; set; }
        [Required(AllowEmptyStrings = false)]
        public string Password { get; set; }
    }
}