using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace AKStore.Entity
{
    public class Customer: UsersBacicFields
    {
        public int Id { get; set; }
        public int DistributorId { get; set; }
        public int UserId { get; set; }
        public int SerialNo { get; set; }
        
        public string StoreName { get; set; }
        [NotMapped]
        public string  UserName { get; set; }
        [NotMapped]
        public string  Password { get; set; }
        [NotMapped]
        public string PhNo1 { get; set; } 

        [NotMapped]
        public string PhNo2 { get; set; }
        [NotMapped]
        public string Address { get; set; }

        public int ? InsertedByUserId { get; set; }
        public int ? UpdatedByUserId { get; set; }
        public DateTime? InsertedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }

    }
}
