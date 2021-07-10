using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

namespace AKStore.Entity
{
    public class Admin: UsersBacicFields
    {
        public int Id { get; set; }
        
        public int UserId { get; set; }
        public DateTime? InsertedDate { get; set; }
        public int ? InsertedByUserId { get; set; }
        public int ? UpdatedByUserId { get; set; }
        public DateTime? UpdatedDate { get; set; }
    }
    public class UsersBacicFields
    {
        [NotMapped]
        public string FirstName { get; set; }
        [NotMapped]
        public string LastName { get; set; }
    }
}