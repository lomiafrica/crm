import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const serverBaseUrl = process.env.REACT_APP_SERVER_BASE_URL;

if (!serverBaseUrl) {
  console.error('Error: REACT_APP_SERVER_BASE_URL is not set.');
  process.exit(1);
}

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const indexPath = path.join(scriptDir, '../build/index.html');

if (!fs.existsSync(indexPath)) {
  console.error(`Error: ${indexPath} not found. Run the front-end build first.`);
  process.exit(1);
}

console.log('Injecting runtime environment variables into index.html...');

const configBlock = `    <script id="twenty-env-config">
      window._env_ = {
        REACT_APP_SERVER_BASE_URL: "${serverBaseUrl}"
      };
    </script>
    <!-- END: Twenty Config -->`;

const html = fs.readFileSync(indexPath, 'utf8');
const updatedHtml = html.replace(
  /<!-- BEGIN: Twenty Config -->[\s\S]*?<!-- END: Twenty Config -->/,
  `<!-- BEGIN: Twenty Config -->\n${configBlock}`,
);

if (updatedHtml === html) {
  console.error('Error: Twenty config markers not found in index.html.');
  process.exit(1);
}

fs.writeFileSync(indexPath, updatedHtml);
