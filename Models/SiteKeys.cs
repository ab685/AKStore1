
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Threading.Tasks;

namespace AKStore.Models
{
    public class SiteKeys
    {
       
        public static string WebSiteDomain => "http://localhost:50335/";
        public static string Token => "WriteMySecretKeyForAuthentication";
    }
}
