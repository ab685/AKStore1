using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace AKStore.Entity
{
    public class Company
    {
        public int Id { get; set; }
        public int DistributorId { get; set; }
        [NotMapped]
        public string CategoryName { get; set; }
        public int CategoryId { get; set; }
        public string Name { get; set; }
        public string FilePath { get; set; }
        public string Description { get; set; }
        public DateTime? InsertedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public int? InsertedByUserId { get; set; }
        public int? UpdatedByUserId { get; set; }
    }
}

