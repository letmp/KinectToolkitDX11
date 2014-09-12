#region usings
using System;
using System.Drawing;
using System.IO;
using System.Text;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using ZXing;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "ZXing", Category = "String", Help = "ZXing decode qrcodes", Tags = "")]
	#endregion PluginInfo
	public class StringZXingNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("raw BMP", DefaultString = "")]
		ISpread<Stream> FStreamIn;

		[Input("Try Hard", DefaultValue = 1.0, IsSingle = true)]
		ISpread<bool> FTryHard;

		[Input("Enabled", DefaultValue = 1.0, IsSingle = true)]
		ISpread<bool> FEnabled;

		[Output("String")]
		ISpread<string> FOutput;

		[Output("Points")]
		ISpread<ISpread<Vector2D>> FPoints;

		[Output("Status")]
		ISpread<int> IStatus;

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			FOutput.SliceCount = 1;
			IStatus.SliceCount = 1;
			if ((FEnabled[0]) && (FStreamIn[0].Length > 16)) {

				var bmp = Bitmap.FromStream(FStreamIn[0]);
				var reader = new ZXing.BarcodeReader { TryHarder = FTryHard[0] };
				var results = reader.DecodeMultiple((Bitmap)bmp);

				if (results != null) {
					for (int i = 0; i < results.Length; i++) {
						var result = results[i];
						FOutput.SliceCount = results.Length;
						FPoints.SliceCount = results.Length;
						IStatus.SliceCount = results.Length;

						FOutput[i] = ((ZXing.Result)(result)).Text;
						FPoints[i].ResizeAndDismiss(0);
						//FLogger.Log(LogType.Debug,results.Length.ToString());

						for (int j = 0; j < result.ResultPoints.Length; j++) {
							var v = new Vector2D((2 * result.ResultPoints[j].X / bmp.Width) - 1, (-2 * result.ResultPoints[j].Y / bmp.Height) + 1);
							FPoints[i].Add(v);
						}
						IStatus[i] = 1;
					}
				} else {
					FOutput[0] = "";
					FPoints[0].SliceCount = 0;
					FPoints[0].ResizeAndDismiss(0);
					IStatus[0] = 0;
				}
			}
		}
	}
}


