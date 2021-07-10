using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AKStore.Entity
{
    public class RetailerDetails
    {
        public int Id { get; set; }
        public int RetailerId { get; set; }
        public int UserId { get; set; }
        public DateTime? InsertedDate { get; set; }
        public int? InsertedByUserId { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public int? UpdatedByUserId { get; set; }
    }
}