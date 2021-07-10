using System;

namespace AKStore.Entity
{
    public class Retailer
    {
        public int Id { get; set; }
        public string Name { get; set; }
       
        public int DistributorId { get; set; }
        public DateTime? InsertedDate { get; set; }
        public int ? InsertedByUserId { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public int? UpdatedByUserId { get; set; }
    }
}