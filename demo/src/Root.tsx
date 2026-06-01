import { Composition } from "remotion";
import { RedeyeDemo } from "./RedeyeDemo";

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="RedeyeDemo"
      component={RedeyeDemo}
      durationInFrames={240}
      fps={30}
      width={1920}
      height={1080}
      defaultProps={{}}
    />
  );
};
