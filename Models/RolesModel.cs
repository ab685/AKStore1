using System;

namespace AKStore.Models
{
    public class RolesModel
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public DateTime? InsertedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
    }
}